page 70004 "Consignment Process Log"
{

    ApplicationArea = All;
    Caption = 'Consignment Process Log';
    PageType = List;
    SourceTable = "Consignment Process Log";
    UsageCategory = History;
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Vendor No."; Rec."Vendor No.") { }
                field("Customer No."; Rec."Customer No.") { }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.") { }
                field("Sales Invoice No."; Rec."Sales Invoice No.") { }
                field("Starting Date"; Rec."Starting Date") { }
                field("Ending Date"; Rec."Ending Date") { }
                field("Email Address"; Rec."Email Address") { }
                field("Email Sent"; Rec."Email Sent") { }
                field("Created By"; Rec."Created By") { }
                field("Created Datetime"; Rec."Created Datetime") { }
                field(PIPath; Rec.PIPath) { }
                field(SIPath; Rec.SIPath) { }
                field(CEPath; Rec.CEPath) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Tick Email Selected")
            {
                ApplicationArea = All;
                Promoted = true;
                Image = PostMail;
                PromotedIsBig = true;
                ToolTip = 'Mark Email Sent for Selected Records';

                trigger OnAction()
                begin
                    MarkSent();
                end;
            }
            action("Untick Email Selected")
            {
                ApplicationArea = All;
                Promoted = true;
                Image = SendMail;
                PromotedIsBig = true;
                ToolTip = 'Resend Email for Selected Records';

                trigger OnAction()
                begin
                    MarkUnsent();
                end;
            }
            action("Regenerating Consignment Report")
            {
                ApplicationArea = All;
                Promoted = true;
                Image = Report2;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    RegenReport();
                end;
            }
        }
    }

    procedure MarkSent()
    begin
        CurrPage.SetSelectionFilter(rec);
        if Rec.FindFirst() then begin
            repeat
                Rec."Email Sent" := true;
                Rec.Modify();
            until Rec.next = 0;
        end;
        clear(Rec);
        Rec.Reset();
    end;

    procedure MarkUnsent()
    begin
        CurrPage.SetSelectionFilter(rec);
        if Rec.FindFirst() then begin
            repeat
                Rec."Email Sent" := False;
                Rec.Modify();
            until Rec.next = 0;
        end;
        clear(Rec);
        Rec.Reset();
    end;


    procedure RegenReport()
    var
        cu: Codeunit "Consignment Util";
        lrecce: Record "Consignment Entries";
        lrecrs: Record "LSC retail setup";
    begin
        // Rec.COPY(Rec);
        // CurrPage.SETSELECTIONFILTER(Rec2);
        CurrPage.SetSelectionFilter(rec);
        if Rec.FindSet() then begin
            repeat
                //REMOVE OLD RECORDS
                clear(lrecce);
                lrecce.SetCurrentKey("Created By", "Vendor No.", Date);
                lrecce.setrange("Created By", userid);
                lrecce.deleteall;

                //CALC NEW RECORDS
                cu.GetInfo(Rec."Vendor No.", Rec."Starting Date", Rec."Ending Date", '');
                cu.CopySalesData(Rec."Starting Date", Rec."Ending Date", '', '');

                //CEReport-
                Clear(lrecce);
                lrecce.SetCurrentKey("Created By", "Vendor No.", Date);
                lrecce.SetRange("Created By", userid);
                lrecce.setrange("Vendor No.", Rec."Vendor No.");
                lrecce.setrange(Date, Rec."Starting Date", Rec."Ending Date");
                if lrecce.FindFirst() then begin
                    if lrecrs.get then
                        lrecrs.TestField("Consignment Attachment Path");
                    //   report.SaveAsPdf(70001, CEPath, lrecce); //Obsolete
                end;
                //CEReport+       

                //REMOVE Cache
                clear(lrecce);
                lrecce.SetCurrentKey("Created By", "Vendor No.", Date);
                LRecCE.setrange("Created By", userid);
                lrecce.deleteall;
            until Rec.Next() = 0;
        end;
        clear(Rec);
        Rec.Reset();
    end;

    local procedure GenPDFInvoice(NewPurchHeader: Record "Purchase Header"; NewSalesHeader: Record "Sales Header"; IsPurch: Boolean): text
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReportSelection: record "Report Selections";
        LRecRS: Record "LSC Retail Setup";
        FileMgmt: Codeunit "File Management";
        ServerTmpPath: text;
    begin
        InitFolder();
        if LRecRS.get then
            lrecrs.TestField("Consignment Attachment Path");

        if IsPurch = true then begin
            PurchHeader := NewPurchHeader;
            PurchHeader.SETRECFILTER;

            PurchSetup.GET;
            IF PurchSetup."Calc. Inv. Discount" THEN BEGIN
                PurchLine.RESET;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine.FINDFIRST;
                CODEUNIT.RUN(CODEUNIT::"Purch.-Calc.Discount", PurchLine);
                PurchHeader.GET(PurchHeader."Document Type", PurchHeader."No.");
                COMMIT;
            END;

            clear(ReportSelection);
            ReportSelection.setrange(usage, ReportSelection.Usage::"P.Test");
            if ReportSelection.FindFirst() then begin
                ServerTmpPath := lrecrs."Consignment Attachment Path" + '\PI_' + PurchHeader."Buy-from Vendor No." + '_' + PurchHeader."No." + '.PDF';
                // if FileMgmt.ServerFileExists(ServerTmpPath) = true then FileMgmt.DeleteServerFile(ServerTmpPath); //Obsolete
                //ServerTmpPath := FileMgmt.ServerTempFileName('pdf');
                // report.SaveAsPdf(ReportSelection."Report ID", ServerTmpPath, PurchHeader); //Obsolete
                exit(ServerTmpPath);
            end;
        end else begin
            SalesHeader := NewSalesHeader;
            SalesHeader.SETRECFILTER;
            SalesSetup.GET;
            IF SalesSetup."Calc. Inv. Discount" THEN BEGIN
                SalesLine.RESET;
                SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                SalesLine.FINDFIRST;
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", SalesLine);
                SalesHeader.GET(SalesHeader."Document Type", SalesHeader."No.");
                COMMIT;
            END;

            clear(ReportSelection);
            ReportSelection.setrange(Usage, ReportSelection.Usage::"S.Test");
            if ReportSelection.FindFirst() then begin
                ServerTmpPath := lrecrs."Consignment Attachment Path" + '\SI_' + SalesHeader."Sell-to Customer No." + '_' + SalesHeader."No." + '.PDF';
                // if FileMgmt.ServerFileExists(ServerTmpPath) = true then FileMgmt.DeleteServerFile(ServerTmpPath); //Obsolete
                //ServerTmpPath := FileMgmt.ServerTempFileName('pdf');
                // report.SaveAsPdf(ReportSelection."Report ID", ServerTmpPath, SalesHeader); //Obsolete
                exit(ServerTmpPath);
            end;
        end;
        exit('');
    end;

    local procedure InitFolder()
    var
        LRecRS: Record "LSC Retail Setup";
        FileMgmt: Codeunit "File Management";
    begin
        if LRecRS.get then
            LRecRS.TestField("Consignment Attachment Path");
        // if not FileMgmt.ServerDirectoryExists(LRecRS."Consignment Attachment Path") then //Obsolete
        //     FileMgmt.ServerCreateDirectory(lrecrs."Consignment Attachment Path"); //Obsolete
    end;

}

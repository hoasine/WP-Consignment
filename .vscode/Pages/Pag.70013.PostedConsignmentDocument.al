page 70013 "Posted Consignment Document"
{
    Caption = 'Posted Consignment Document';
    PageType = Card;
    SourceTable = "Consignment Header";
    SourceTableView = where(Status = filter('2'));
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = (Rec.status = rec.status::Open);
                field("Document No."; Rec."Document No.") { Importance = Promoted; ApplicationArea = All; ToolTip = 'Specifies the value of the Document No. field.'; }
                field("Vendor No."; Rec."Vendor No.") { Importance = Promoted; ApplicationArea = All; ShowMandatory = true; ToolTip = 'Specifies the value of the Vendor No. field.'; }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Start Date field.';
                    trigger OnValidate()
                    begin
                        if format(rec."End Date") <> '' then begin
                            CheckDates();
                        end;
                    end;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the End Date field.';
                    trigger OnValidate()
                    begin
                        if format(rec."Start Date") <> '' then begin
                            CheckDates();
                        end;
                    end;
                }
                field("Document Date"; Rec."Document Date") { ApplicationArea = All; ToolTip = 'Specifies the value of the Document Date field.'; }
                field(Status; Rec.Status) { ApplicationArea = All; ToolTip = 'Specifies the value of the Status field.'; }

                group(Documents)
                {
                    Caption = 'Documents Information';

                    field("Sales Invoice No."; rec."Sales Invoice No.") { ApplicationArea = all; }
                    field("Posted Sales Invoice No."; rec."Posted Sales Invoice No.") { ApplicationArea = all; }
                    field("Purchase Invoice No."; rec."Purchase Invoice No.")
                    {
                        ApplicationArea = all;
                        trigger OnDrillDown()
                        var
                            ph: Record "Purchase Header";
                        begin
                            ph.setrange("Document Type", ph."Document Type"::Invoice);
                            ph.setrange("Consign. Document No.", rec."Document No.");
                            if ph.FindFirst() then
                                page.RunModal(9308, ph);
                        end;
                    }
                    field("Posted Purchase Invoice No."; rec."Posted Purchase Invoice No.") { ApplicationArea = All; }
                }
            }

            part(csl; "Consignment Document Lines")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Document No.");
                Editable = false;
            }
            part(cbl; "Consignment Billing Entries")
            {
                Caption = 'Billing Entries';
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Document No.");
                Editable = false;
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(Reopen)
            {
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = (rec.status = rec.status::Released);

                trigger OnAction()
                begin
                    rec.TestField(Status, rec.Status::Released);
                    rec.Status := rec.Status::Open;
                    rec.Modify();
                    CurrPage.Update(false);
                end;
            }
            action(Clear)
            {
                image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = (rec.status = rec.status::Open);
                trigger OnAction()
                begin
                    if Confirm('Reset Calculation?') = true then begin
                        ClearDocument();
                    end;
                end;
            }
            action("Calculate Consignment Entries")
            {
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                Visible = (rec.Status = rec.Status::Open);
                trigger OnAction();
                var
                    ConsignmentHeader: Record "Consignment Header";
                begin
                    rec.TestField(Status, rec.status::Open);
                    Rec.TestField("Vendor No.");
                    CalcConsign();

                    ConsignmentHeader.Reset();
                    ConsignmentHeader.setrange("Document No.", rec."Document No.");
                    ConsignmentHeader.SetLoadFields(Status);
                    if ConsignmentHeader.FindFirst() then begin
                        ConsignmentHeader.status := ConsignmentHeader.Status::Released;
                        ConsignmentHeader.Modify();
                    end;
                end;
            }
            action("Release")
            {
                image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = (rec.Status = rec.Status::Open);

                trigger OnAction();
                var
                    lines: Record "Consignment Entries";//001
                    errorMsg: TextConst ENU = 'Youre not allowed to release document without lines.\n do you want to delete the current document %1 ?';//001
                    errorCancelled: TextConst ENU = 'Release action cancelled.';//001
                begin
                    //001-
                    lines.Reset();
                    lines.setrange("Document No.", rec."Document No.");
                    if lines.Count = 0 then begin
                        if Confirm(StrSubstNo(errorMsg, rec."Document No.")) = true then begin
                            rec.delete;
                            CurrPage.Update(false);
                            exit;
                        end else begin
                            error(errorCancelled);
                            exit;
                        end;
                    end;
                    //001+
                    rec.status := rec.status::Released;
                    rec.modify;
                    CurrPage.Update(false);
                end;
            }
            //20200915 CONSIGNMENT-
            action("Post")
            {
                Image = Post;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (rec.Status = rec.Status::Released);
                trigger OnAction();
                var
                    LRecCE: Record "Consignment Entries";
                    ch: Record "Consignment Header";
                begin
                    rec.TestField(Status, rec.Status::Released);
                    clear(lrecce);
                    lrecce.setrange("Document No.", rec."Document No.");
                    //lrecce.setrange("Created By", UserId);
                    //lrecce.setrange("USER SID", UserSecurityId);//20201126
                    if lrecce.findfirst then begin
                        if Confirm(StrSubstNo('Create Invoice(s) for %1 record(s)?', format(LRecCE.count))) = true then
                            CreateInvoices(LRecCE, rec);

                        clear(ch);
                        ch.setrange("Document No.", rec."Document No.");
                        if ch.FindFirst() then begin
                            ch.status := ch.Status::Posted;
                            ch.modify;
                        end;
                    end else
                        error('Nothing to process.');

                    CurrPage.close;
                end;
            }
            //20200915 CONSIGNMENT+

            action("Send Email")
            {
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                PromotedIsBig = true;
                Visible = (rec.Status >= 1);
                trigger OnAction()
                var
                    ConsignUtil: Codeunit "Consignment Util";
                begin
                    if ConsignUtil.ConsignDocSendEmail(rec) = true then begin
                        rec."Email Sent" := true;
                        rec."E-Mail Sent Timestamp" := CurrentDateTime;
                        rec."E-Mail Sent User ID" := UserId;
                        rec.modify;
                    end;
                end;
            }
            action("Test Email")
            {
                Image = Post;
                Promoted = true;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                trigger OnAction()
                var
                    ConsignUtil: Codeunit "Consignment Util";
                begin
                    ConsignUtil.testSendEmail();
                end;
            }
        }
        area(Reporting)
        {
            action("Consignment Report")
            {
                Image = Report;
                Promoted = true;
                ApplicationArea = All;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    recConsignEntry: Record "Consignment Entries";
                begin
                    Clear(recConsignEntry);
                    recConsignEntry.Reset();
                    recConsignEntry.setrange("Document No.", rec."Document No.");
                    recConsignEntry.SetRange(Date, rec."Start Date", rec."End Date");
                    if recConsignEntry.FindFirst() then;
                    Report.RunModal(70001, true, false, recConsignEntry);
                end;
            }

            action("Consignment Sales Report")
            {
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                var
                    recConsignEntry: Record "Consignment Entries";
                begin
                    Clear(recConsignEntry);
                    recConsignEntry.Reset();
                    recConsignEntry.SetRange("Document No.", rec."Document No.");
                    recConsignEntry.SetRange(Date, rec."Start Date", rec."End Date");
                    if recConsignEntry.FindFirst() then;
                    Report.RunModal(70003, true, false, recConsignEntry);
                end;

            }
            //20200930+
            action("Test_ClearConsignmentLogs")
            {
                Image = TestReport;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    con: Codeunit "Consignment Util";
                begin
                    con.TestPDF();
                end;
            }
            action("Test_Calc.ConsignmentEntries")
            {
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                var
                    con: Codeunit "Calc. Consignment";
                begin
                    con.Run();
                end;
            }
            // action("Test_EMailConsignment")
            // {
            //     Image = TestFile;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     Visible = false;
            //     trigger OnAction()
            //     var
            //         con: Codeunit "EMail Consignment";
            //     begin
            //         con.Run();
            //     end;
            // }

            action(POSStatementRpt)
            {
                Caption = 'POS Statement Report';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ConsignHeader: Record "Consignment Header";
                begin
                    ConsignHeader.Reset();
                    ConsignHeader.SetRange("Document No.", Rec."Document No.");
                    if ConsignHeader.FindFirst() then;
                    Report.RunModal(Report::"POS Statement Report", true, false, ConsignHeader);
                end;
            }
        }
    }

    local procedure CheckDates()
    var
        LText001: TextConst ENU = '%1 can not be earlier than %2';
    begin
        IF (rec."Start Date" <> 0D) AND (rec."End Date" <> 0D) AND (rec."Start Date" > rec."End Date") THEN
            ERROR(LText001, 'Ending Date', 'Starting Date');
    end;

    local procedure PrintReport()
    var
        recConsignEntry: Record "Consignment Entries";
    begin
        Clear(recConsignEntry);
        recConsignEntry.Reset();
        if rec."Vendor No." <> '' then
            recConsignEntry.SetRange("Vendor No.", rec."Vendor No.");
        recConsignEntry.SetRange("USER SID", UserSecurityId());
        if recConsignEntry.FindFirst() then;
        Report.RunModal(70002, true, false, recConsignEntry);
    end;

    local procedure CalcConsign()
    var
        LText001: TextConst ENU = '%1 can no be empty';
        cuconsignutil: Codeunit "Consignment Util";
        StoreNo: Code[20];
    begin
        if rec."Start Date" = 0D then Error(LText001, 'Starting Date');
        if rec."End Date" = 0D then Error(LText001, 'Ending Date');
        checkDuplicate();//002
        Clear(cuConsignUtil);
        cuConsignUtil.DeleteSalesDateByDocument_ALL(rec."Document No.");
        cuConsignUtil.GetInfo(rec."Vendor No.", rec."Start Date", rec."End Date", StoreNo);
        cuConsignUtil.CopySalesData2(rec."Start Date", rec."End Date", StoreNo, rec."Vendor No.", rec."Document No.");
        // cuconsignutil.CreateBillingEntries(rec."Document No.");
        CurrPage.Update(false);
    end;

    local procedure CreateInvoices(ce: Record "Consignment Entries"; ch: Record "Consignment Header")
    var
        cuConsignUtil: Codeunit "Consignment Util";
    begin
        clear(cuConsignUtil);
        //cuConsignUtil.CreateInvoices(ce, sdate, edate, false);
        cuConsignUtil.CreateInvoices2(ce, ch);
    end;

    local procedure ClearDocument()
    var
        cuConsignUtil: Codeunit "Consignment Util";
    begin
        clear(cuConsignUtil);
        cuConsignUtil.DeleteSalesDateByDocument_ALL(rec."Document No.");
        CurrPage.Update(false);
    end;
    //002-
    local procedure CheckDuplicate()
    var
        header: Record "Consignment Header";
        errorMsg: TextConst ENU = 'The same document with the same filter already exists, %1, %2, %3, and Status: Open.\nPlease delete/recalculate the document %4 before creating a new document.\nDo you want to delete the current document?';
    begin
        clear(header);
        header.SetCurrentKey(Status, "Start Date", "End Date");
        header.setrange(Status, header.Status::Open);
        header.setrange("Start Date", rec."Start Date");
        header.setrange("End Date", rec."End Date");
        header.setrange("Vendor No.", rec."Vendor No.");
        if header.FindSet() then begin
            repeat
                if header."Document No." <> rec."Document No." then begin
                    if Confirm(StrSubstNo(errorMsg, header."Vendor No.", format(header."Start Date"), format(header."End Date"), rec."Document No.")) = true then begin
                        Rec.Delete(true);
                        CurrPage.update(false);
                    end else begin
                        error('');
                        CurrPage.Update(false);
                    end;
                end;
            until header.next = 0;
        end;
    end;
    //002+
}
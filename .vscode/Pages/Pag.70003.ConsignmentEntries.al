
page 70003 "Consignment Entries"
{
    PageType = List;
    SourceTable = "Consignment Entries";
    SourceTableView = where("Document No." = filter('')); //20240124-+
    UsageCategory = nonE;
    ObsoleteState = Pending;
    ObsoleteReason = 'To be replaced by new page Consignment Document';
    PromotedActionCategories = 'New,Process,Report';
    InsertAllowed = false;
    ApplicationArea = All;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(Filter)
            {
                field("Starting Date"; dtStart)
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CheckDates();
                    end;
                }
                field("Ending Date"; dtEnd)
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        CheckDates();
                    end;
                }
                field("VendNo"; VendNo)
                {
                    Caption = 'Vendor No.';
                    TableRelation = Vendor."No.";
                }
                field("StoreNo"; StoreNo)
                {
                    Caption = 'Store No.';
                    TableRelation = "LSC Store"."No.";
                }
                field(EventContractFilter; EventContractFilter)
                {
                    Caption = 'Event Contract Filter';
                }

            }
            repeater(GroupName)
            {
                Editable = false;
                FreezeColumn = "Item No.";
                field(Date; Rec.Date) { }
                field("Store No."; Rec."Store No.") { }
                field("Vendor No."; Rec."Vendor No.") { }
                field(Division; Rec.Division) { }
                field("Item Category"; Rec."Item Category") { }
                field("Product Group"; Rec."Product Group") { }
                field("Special Group"; Rec."Special Group") { }
                field("Special Group 2"; Rec."Special Group 2") { } //20240513-+
                field("Item No."; Rec."Item No.") { }
                field("Item Description"; Rec."Item Description") { }
                field("Receipt No."; Rec."Receipt No.") { }
                field("Barcode No."; Rec."Barcode No.") { }
                field("Currency Code"; Rec."Currency Code") { }
                field("Exch. Rate"; Rec."Exch. Rate") { }
                field(Quantity; Rec.Quantity) { DecimalPlaces = 0 : 3; }
                field(Price; Rec.Price) { }
                field(UOM; Rec.UOM) { }
                field("Net Amount (LCY)"; Rec."Net Amount (LCY)") { }
                field("VAT per unit"; Rec."VAT per unit") { }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)") { }
                field("Cost Amount (LCY)"; Rec."Cost Amount (LCY)") { }
                field("Promotion No."; Rec."Promotion No.") { }
                field("Periodic Disc. Type"; Rec."Periodic Disc. Type") { }
                field("Periodic Offer No."; Rec."Periodic Offer No.") { }
                field("Total Discount"; Rec."Total Discount") { }
                field("Periodic Discount Amount (LCY)"; Rec."Periodic Discount Amount (LCY)") { }
                field("VAT Code"; Rec."VAT Code") { }
                field("Gross Price"; Rec."Gross Price") { }
                field("Disc. Amount From Std. Price"; Rec."Disc. Amount From Std. Price") { Caption = 'Disc per unit'; }
                field("Discount Amount (LCY)"; Rec."Discount Amount (LCY)") { Caption = 'Discount Amount Excl. Tax'; }
                field("Net Price Incl Tax"; Rec."Net Price Incl Tax") { }
                field("Total Incl Tax"; Rec."Total Incl Tax") { }
                field(Tax; Rec.Tax * -1) { }
                field("Total Tax Collected"; Rec."Total Tax Collected" * -1) { }
                field("Net Price Excl Tax"; Rec."Net Price Excl Tax") { }
                field("Total Excl Tax"; Rec."Total Excl Tax") { Caption = 'Sale Price'; }
                field("Tax Rate"; Rec."Tax Rate") { Caption = 'Tax rate'; }
                field(Cost; Rec.Cost) { }
                field("Cost Incl Tax"; Rec."Cost Incl Tax") { Caption = 'Cost Incl Tax'; }
                field("Consignment Amount"; Rec."Consignment Amount") { Caption = 'Profit Excl Tax'; }
                field("Consignment Amount (LCY)"; Rec."Consignment Amount (LCY)") { Caption = 'Profit (LCY)'; Visible = false; }
                field("Consignment %"; Rec."Consignment %") { Caption = 'Profit Margin %'; }
                field("Return No Sales"; Rec."Return No Sales") { }
                field("Member Card No."; Rec."Member Card No.") { }
                field("Consignment Type"; Rec."Consignment Type") { }
                field("Created By"; Rec."Created By") { }
                field("Created Date"; Rec."Created Date") { }
                field("Item Family Code"; Rec."Item Family Code") { }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Calculate Consignment Entries")
            {
                Image = Calculate;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    CalcConsign();
                end;
            }
            action("Create Invoice")
            {
                Image = Invoice;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    CreateInvoice();
                end;
            }
            //20200915 CONSIGNMENT-
            action("Create Invoice & E-Mail")
            {
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction();
                var
                    LRecCE: Record "Consignment Entries";
                begin
                    clear(lrecce);
                    lrecce.setrange("Created By", UserId);
                    lrecce.setrange("USER SID", UserSecurityId);//20201126
                    if lrecce.findfirst then begin
                        if Confirm(StrSubstNo('Create Invoice(s) for %1 record(s)?', format(LRecCE.count))) = true then begin
                            cuConsignUtil.CreateInvoices(LRecCE, dtStart, dtEnd, false);
                        end;
                    end else begin
                        error('Nothing to process.');
                    end;
                end;
            }
            //20200915 CONSIGNMENT+
        }
        area(Reporting)
        {
            action("Consignment Report")
            {
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    recConsignEntry: Record "Consignment Entries";
                begin
                    Clear(recConsignEntry);
                    recConsignEntry.Reset();
                    recConsignEntry.SetRange(Date, dtStart, dtEnd);
                    recConsignEntry.SetRange("USER SID", Rec."USER SID");
                    if recConsignEntry.FindFirst() then;
                    Report.RunModal(70001, true, false, recConsignEntry);
                end;
                //RunObject = report "Consignment Report";
            }
            //20200930-
            action("Consignment Sales Report")
            {
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    recConsignEntry: Record "Consignment Entries";
                begin
                    Clear(recConsignEntry);
                    recConsignEntry.Reset();
                    recConsignEntry.SetRange(Date, dtStart, dtEnd);
                    recConsignEntry.SetRange("USER SID", Rec."USER SID");
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
            // action("Test_EMAIL")
            // {
            //     Image = TestFile;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         Email: Codeunit "Document-Mailing";
            //         CE: Record "Consignment Process Log";
            //         FM: Codeunit "File Management";
            //         TempPath: text;
            //     begin
            //         ce.get(1);
            //         TempPath := fm.ServerTempFileName('html');
            //         report.SaveAsHtml(70002, TempPath, ce);
            //         email.EmailFile('C:\LSRETAIL.INI', 'LSRETAIL.INI', TempPath, '', 'EDDY.ONG@RGTECH.COM.MY', 'Monthly Invoices', true, 0);
            //         email.EmailFile('C:\LSRETAIL.INI', 'LSRETAIL.INI', TempPath, '', 'kaixin.wONG@RGTECH.COM.MY;ivan.lau@rgtech.com.my', 'Monthly Invoices', true, 0);
            //     end;
            // }
        }
    }

    local procedure CheckDates()
    var
        LText001: TextConst ENU = '%1 can not be earlier than %2';
    begin
        IF (dtStart <> 0D) AND (dtEnd <> 0D) AND (dtStart > dtEnd) THEN
            ERROR(LText001, 'Ending Date', 'Starting Date');
    end;

    local procedure PrintReport()
    var
        recConsignEntry: Record "Consignment Entries";
    begin
        Clear(recConsignEntry);
        recConsignEntry.Reset();
        if VendNo <> '' then
            recConsignEntry.SetRange("Vendor No.", VendNo);
        recConsignEntry.SetRange("USER SID", UserSecurityId());
        if recConsignEntry.FindFirst() then;
        Report.RunModal(70002, true, false, recConsignEntry);
    end;

    local procedure CalcConsign()
    var
        LText001: TextConst ENU = '%1 can no be empty';
    begin
        if dtStart = 0D then Error(LText001, 'Starting Date');
        if dtEnd = 0D then Error(LText001, 'Ending Date');
        Clear(cuConsignUtil);
        cuConsignUtil.DeleteSalesDateBySession();
        cuConsignUtil.GetInfo(VendNo, dtStart, dtEnd, StoreNo);
        cuConsignUtil.CopySalesData(dtStart, dtEnd, StoreNo, VendNo);
        //cuConsignUtil.CopySalesData2(dtStart, dtEnd, StoreNo, VendNo);
        CurrPage.Update(false);
    end;

    local procedure CreateInvoice()
    begin

    end;

    trigger OnOpenPage()
    begin
        Clear(cuConsignUtil);
        cuConsignUtil.DeleteSalesDateBySession();
        rec.setrange("USER SID", UserSecurityId());
        rec.FilterGroup(0);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        Clear(cuConsignUtil);
        cuConsignUtil.DeleteSalesDateBySession();
    end;

    var
        VendNo: Code[20];
        StoreNo: Code[20];
        dtStart: Date;
        dtEnd: Date;
        cuConsignUtil: Codeunit "Consignment Util";
        rptConsign: Report "Consignment Report";
        EventContractFilter: text;

}
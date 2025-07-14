page 70016 "Daily Consignment Checklist"
{
    /* PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Daily Consignment Checklist";
    CardPageId = "Daily Consign. Checklist Card";
    SourceTableView = sorting("Generated Date Time") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false; */

    Caption = 'Consignment Daily Check List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Daily Consign. Sales Details";
    SaveValues = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(Content)
        {

            /*  repeater(GroupName)
             {
                 field("Document No."; Rec."Document No.") { }
                 field("Generated Date Time"; Rec."Generated Date Time") { }
             } */

            repeater(Details)
            {
                field("Store No."; Rec."Store No.") { }
                field("Receipt No."; Rec."Receipt No.") { }
                field("Date"; Rec."Date") { }
                field("Vendor No."; Rec."Vendor No.") { }
                field("Division"; Rec."Division") { }
                field("Item Category"; Rec."Item Category") { }
                field("Item No."; Rec."Item No.") { }
                field("Gross Price"; Rec."Gross Price") { }
                field("Total Excl Tax"; Rec."Total Excl Tax") { }
                field("VAT Amount"; Rec."Total Incl Tax" - Rec."Total Excl Tax") { }
                field("Total Incl Tax"; Rec."Total Incl Tax") { }
                field("Cost Incl Tax"; Rec."Cost Incl Tax") { }
                field("MDR Rate Pctg"; Rec."MDR Rate Pctg") { }
                field("MDR Rate"; Rec."MDR Rate") { }
                field("MDR Amount"; Rec."MDR Amount") { }
                field("Profit %"; Rec."Profit %") { }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Calculate Consignment Daily")
            {
                Image = Calculate;
                Promoted = true;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    ConsDetail: Codeunit "Calculate Sales Entries";
                begin
                    ConsDetail.NewCalculateSalesEntries();
                    CurrPage.Update(false);
                end;
            }
        }
    }
    var
        DocNoFilter: Text;
        VendNoFilter: Text;
        ConsignmentPeriodStartDate: Date;
        ConsignmentPeriodEndDate: Date;
        ConsignmentDetail: Record "Daily Consign. Sales Details";
}
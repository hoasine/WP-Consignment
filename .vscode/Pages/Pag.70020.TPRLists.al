page 70020 "TPR List"
{
    Caption = 'Trading Profit List';
    PageType = List;
    SourceTable = "TPR Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'TPR, Trading Profit Report';
    RefreshOnActivate = true;
    Editable = false;
    CardPageId = "TPR";

    layout
    {
        area(Content)
        {
            repeater(TPRHeader)
            {
                field("Batch No."; Rec."Batch No.") { }
                field("Store No."; Rec."Store No.") { }
                field("Store Name"; Rec."Store Name") { }
                field("Date"; Rec."Date") { }
                field("MTD Start Date"; Rec."MTD Start Date") { StyleExpr = 'StrongAccent'; }
                field("MTD End Date"; Rec."MTD End Date") { StyleExpr = 'StrongAccent'; }
                field("YTD Start Date"; Rec."YTD Start Date") { StyleExpr = 'StrongAccent'; }
                field("YTD End Date"; Rec."YTD End Date") { StyleExpr = 'StrongAccent'; }
                field("Created By"; Rec."Created By") { }
                field("Last Calculated Date"; Rec."Last Calculated Date") { StyleExpr = 'Favorable'; }
                field(Status; Rec.Status) { StyleExpr = 'Favorable'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculate)
            {
                Caption = 'Calculate Trading Profit';
                Image = JobLedger;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    Rec.RunRptToCalcTradingProfit();
                end;
            }
        }
        area(Reporting)
        {
            action(MonthlyTPRRetailProdGrp)
            {
                Caption = 'Monthly TPR By Retail Product Group';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Rec.RunRptMonthlyTPRRetailProdGrp();
                end;
            }
            action(MonhtlyTPRSpecialGroup)
            {
                Caption = 'Monthly TPR By Special Group';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction()
                begin
                    Rec.RunRptMonhtlyTPRSpecialGroup();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Store Name");
    end;

    var
        TPR: Record TPR;
        cuCalcTPR: Codeunit "Calculate TPR";
        gfilterStoreNo: Code[20];
        gfilterDate: date;
        gFromItemNo: Code[100];
        gDiv: Code[20];
        gItemCat: Code[20];
        gProdGrp: Code[20];
        gGenProdPostGroup: Enum itemType;
        gInvPostGroup: Code[10];
        gSpecialGroup: Code[10];
        gblnShowDetails: Boolean;
}
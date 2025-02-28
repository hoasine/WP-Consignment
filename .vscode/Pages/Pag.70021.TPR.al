page 70021 TPR
{
    Caption = 'Trading Profit Report';
    PageType = Document;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TPR Header";
    ShowFilter = true;
    RefreshOnActivate = true;
    DataCaptionFields = "Store No.", "Date";

    layout
    {
        area(Content)
        {

            group(General)
            {
                field("Batch No."; Rec."Batch No.")
                {
                    Caption = 'Batch No.';
                    Importance = Additional;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssitEdit() then CurrPage.Update();
                    end;
                }
                field("Store No."; Rec."Store No.")
                {
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Store Name");
                    end;
                }
                field("Store Name"; Rec."Store Name") { }
                field("Date"; Rec."Date") { ShowMandatory = true; }
                field("MTD Start Date"; StrSubstNo('%1..%2', Rec."MTD Start Date", Rec."MTD End Date")) { Caption = 'Month-To-Date'; StyleExpr = 'StrongAccent'; }
                field("YTD Start Date"; StrSubstNo('%1..%2', Rec."YTD Start Date", Rec."YTD End Date")) { Caption = 'Year-To-Date'; StyleExpr = 'StrongAccent'; }
                field("Last Calculated Date"; Rec."Last Calculated Date") { StyleExpr = 'Favorable'; }
                field(Status; Rec.Status) { StyleExpr = 'Favorable'; }
                group(Filtering)
                {
                    Caption = 'Filtering Options';
                    field("Item No. Filters"; Rec."Item No. Filters") { }
                    field("Division Filters"; Rec."Division Filters") { }
                    field("Item Category Filters"; Rec."Item Category Filters") { }
                    field("Retail Product Group Filters"; Rec."Retail Product Group Filters") { }
                    field("Special Group Filters"; Rec."Special Group Filters") { }
                    field("Item Type Filters"; Rec."Item Type Filters") { StyleExpr = 'StrongAccent'; }
                }
            }

            part(Lines; "TPR Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Batch No." = field("Batch No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SchedulerCalc)
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
}
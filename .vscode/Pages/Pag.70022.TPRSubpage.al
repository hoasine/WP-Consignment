page 70022 "TPR Subpage"
{
    PageType = ListPart;
    SourceTable = TPR;
    ShowFilter = true;
    SourceTableView = sorting("Store No.", "Item No.");
    InsertAllowed = false;
    ApplicationArea = all;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                Editable = false;
                Caption = 'Lines';
                field(Type; Rec.Type) { Caption = 'TYPE'; }
                field("Start Date"; Rec."Start Date") { Visible = false; }
                field("End Date"; Rec."End Date") { Visible = false; }
                field("Store No."; Rec."Store No.") { }
                field(Division; Rec.Division) { }
                field("Item Category"; Rec."Item Category") { }
                field("Retail Product Group"; Rec."Retail Product Group") { }
                field("Item No."; Rec."Item No.") { }
                field(Description; Rec.Description) { }
                field("Item Type"; Rec."Item Type") { }
                field("Special Group Code"; Rec."Special Group Code") { }
                field("Special Group Desc"; Rec."Special Group Desc") { }

                field("Sales Amount"; Rec."Sales Amount") { }
                field("Cost Amount"; Rec."Cost Amount") { }

                field("Net Profit Actual"; Rec."Net Profit Actual Cost") { }
                field("Net Profit Margin"; Rec."Net Profit Margin") { }

                field("Opening Inventory"; Rec."Opening Inventory") { }
                field("Opening Inv Ratio"; Rec."Opening Inv Ratio") { }

                field("Net Purchase"; Rec."Net Purchase") { }
                field("Net Purchase Ratio"; Rec."Net Purchase Ratio") { }

                field("Markdown Actual"; Rec."Markdown Actual") { }
                field("Markdown Ratio"; Rec."Markdown Ratio") { }

                field("Stock Loss"; Rec."Stock Loss") { }
                field("Stock Loss Ratio"; Rec."Stock Loss Ratio") { }

                field("Ending Inventory"; Rec."Ending Inventory") { }
                field("Ending Inv Ratio"; Rec."Ending Inv Ratio") { }

            }
        }
    }
}
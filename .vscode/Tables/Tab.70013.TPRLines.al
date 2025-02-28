table 70013 TPR
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Type; Code[20]) { }
        field(2; "Batch No."; Code[20]) { }
        field(5; "Store No."; Code[20]) { Caption = 'STORE'; }
        field(10; "Item No."; Code[20]) { Caption = 'ITEM CODE'; }
        field(11; "Description"; Text[100]) { Caption = 'DESCRIPTION'; }
        field(20; "Special Group Code"; Code[20]) { Caption = 'SPECIAL GROUP CODE'; }
        field(21; "Special Group Desc"; Text[100]) { Caption = 'SPECIAL GROUP NAME'; }
        field(30; "Division"; Code[10]) { Caption = 'DIVISION'; }
        field(40; "Item Category"; Code[20]) { Caption = 'ITEM CATEGORY'; }
        field(50; "Retail Product Group"; Code[20]) { Caption = 'RETAIL PRODUCT GROUP'; }
        field(60; "Item Type"; Code[20]) { Caption = 'ITEM TYPE'; }

        field(100; "Sales Amount"; Decimal) { Caption = 'SALES'; }
        field(110; "Cost Amount"; Decimal) { Caption = 'COST'; }

        field(120; "Net Profit Actual Cost"; Decimal) { Caption = 'NET PROFIT (ACTUAL)'; }
        field(121; "Net Profit Actual Retail"; Decimal) { }
        field(122; "Net Profit Margin"; Decimal) { Caption = 'NET PROFIT (MARGIN)'; }

        field(200; "Opening Inv Actual Cost"; Decimal) { }
        field(201; "Opening Inv Actual Retail"; Decimal) { }
        field(202; "Opening Inv Ratio"; Decimal) { Caption = 'OPENING INVENTORY (RATIO)'; }
        field(203; "Opening Inv Qty"; decimal) { DecimalPlaces = 0 : 2; }
        field(204; "Opening Inventory"; Decimal) { Caption = 'OPENING INVENTORY (ACTUAL)'; }

        field(210; "Price Per Unit"; Decimal) { }

        field(220; "Net Purchase Actual Cost"; Decimal) { }
        field(221; "Net Purchase Actual Retail"; Decimal) { }
        field(222; "Net Purchase Ratio"; Decimal) { Caption = 'NET PURCHASE (RATIO)'; }
        field(223; "Net Purchase Qty"; Decimal) { }
        field(224; "Net Purchase"; Decimal) { Caption = 'NET PURCHASE (ACTUAL)'; }

        field(230; "Markdown Actual"; Decimal) { Caption = 'MARKDOWN (ACTUAL)'; }
        field(231; "Markdown Ratio"; Decimal) { Caption = 'MARKDOWN (RATIO)'; }
        field(232; "Markdown"; Decimal) { Caption = 'MARKDOWN (ACTUAL)'; }

        field(240; "Stock Loss Actual Cost"; Decimal) { }
        field(241; "Stock Loss Actual Retail"; Decimal) { }
        field(242; "Stock Loss Ratio"; Decimal) { Caption = 'STOCK LOSS (RATIO)'; }
        field(243; "Stock Loss Qty"; Decimal) { }
        field(244; "Stock Loss"; Decimal) { Caption = 'STOCK LOSS (ACTUAL)'; }

        field(250; "Ending Inv Actual Cost"; Decimal) { }
        field(251; "Ending Inv Actual Retail"; Decimal) { }
        field(252; "Ending Inv Ratio"; Decimal) { Caption = 'ENDING INVENTORY (RATIO)'; }
        field(253; "Ending Inventory"; Decimal) { Caption = 'ENDING INVENTORY (ACTUAL)'; }

        field(500; "Start Date"; Date) { Caption = 'START DATE'; }
        field(501; "End Date"; Date) { Caption = 'END DATE'; }
    }


    keys
    {
        key(PK; "Batch No.", Type, "Store No.", "Item No.", "Special Group Code")
        {
            Clustered = true;
        }
        key(Key2; "Store No.", "Item No.", "Item Type") { }
    }
}
report 70007 "TPR By Special Group"
{
    Caption = 'Monthly TPR By Special Group';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    ApplicationArea = All;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70007.TPRBySpecialGrp.rdl';
    AdditionalSearchTerms = 'TPR,Trading Profit, Special Group';

    dataset
    {
        dataitem(TPR; TPR)
        {
            DataItemTableView = sorting("Store No.", "Item No.", "Item Type");
            RequestFilterFields = "Batch No.";

            column(storeNo; "Store No.") { }
            column(storeName; recStore.name) { }
            column(endDate; "End Date") { }
            column(type; "Type") { }
            column(division; Division) { }
            column(itemCategory; "Item Category") { }
            column(retailProductGroup; "Retail Product Group") { }
            column(itemType; "Item Type") { }
            column(specialGroupCode; "Special Group Code") { }
            column(specialGroupName; "Special Group Desc") { }
            column(itemNo; "Item No.") { }
            column(description; Description) { }
            column(sales; "Sales Amount") { }
            column(cost; "Cost Amount") { }
            column(netProfit; "Net Profit Actual Cost") { }
            column(netProfitMargin; "Net Profit Margin") { }

            column(Opening_Inventory; "Opening Inventory") { }
            column(openingInv; "Opening Inv Actual Cost") { }
            column(OpeningInvRetail; "Opening Inv Actual Retail") { }
            column(openingInvRatio; "Opening Inv Ratio") { }

            column(Net_Purchase; "Net Purchase") { }
            column(netPurchaseActual; "Net Purchase Actual Cost") { }
            column(netPurchaseRetail; "Net Purchase Actual Retail") { }
            column(netPurchaseRatio; "Net Purchase Ratio") { }

            column(markdownActual; "Markdown Actual") { }
            column(markdownRatio; "Markdown Ratio") { }

            column(stockLoss; "Stock Loss") { }
            column(stockLossActual; "Stock Loss Actual Cost") { }
            column(stockLossRetail; "Stock Loss Actual Retail") { }
            column(stockLossRatio; "Stock Loss Ratio") { }

            column(Ending_Inventory; "Ending Inventory") { }
            column(endingInvActual; "Ending Inv Actual Cost") { }
            column(endingInvRetail; "Ending Inv Actual Retail") { }
            column(endingInvRatio; "Ending Inv Ratio") { }

            trigger OnAfterGetRecord()
            begin
                if recStore.Get("Store No.") then;
            end;
        }
    }
    var
        recStore: Record "LSC Store";
}
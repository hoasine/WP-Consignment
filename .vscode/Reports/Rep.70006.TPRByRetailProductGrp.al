report 70006 "TPR By Retail Product Group"
{
    Caption = 'Monthly TPR By Retail Product Group';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    ApplicationArea = All;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70006.TPR.rdl';
    AdditionalSearchTerms = 'TPR,Trading Profit, Retail Product Group';
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
            column(divisionName; recDivision.Description) { }
            column(itemCategory; "Item Category") { }
            column(itemCategoryName; recItemCategory.Description) { }
            column(retailProductGroup; "Retail Product Group") { }
            column(retailProductGroupName; recRetailProductGroup.Description) { }
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
                if recDivision.Get(Division) then;
                if recItemCategory.Get("Item Category") then;
                if recRetailProductGroup.Get("Item Category", "Retail Product Group") then;
            end;
        }
    }
    var
        recStore: Record "LSC Store";
        recDivision: Record "LSC Division";
        recItemCategory: Record "Item Category";
        recRetailProductGroup: Record "LSC Retail Product Group";
}
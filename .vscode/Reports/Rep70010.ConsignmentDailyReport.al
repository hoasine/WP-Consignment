report 70010 "Consignment Daily Report"
{
    ApplicationArea = All;
    Caption = 'Consignment Daily Report';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70010.WPConsignmentDailyReport.rdl';
    dataset
    {
        /*
        dataitem(CE; "Consignment Entries")
        {
            RequestFilterFields = Date, "Store No.", Division, "Product Group", "Special Group";
            column(Brand; "Special Group") { }
            column(BrandName; BrandName) { }
            column(Quantity; Quantity) { }
            column(SalesPrice; "Total Incl Tax") { }
            column(CostRate; CostRatePctg) { }
            column(CostPrice; CostPrice) { }
            column(VATCode; "VAT Code") { }
            column(TaxRate; "Tax Rate") { }
            column(Tax; "VAT Amount") { }
            column(Transaction_No_; "Transaction No.") { }
            column(ItemNo; "Item No.") { }
            column(Description; "Item Description") { }

            column(SalesAmount; "Total Incl Tax") { }
            column(Store_No_; "Store No.") { }
            column(StoreName; StoreName) { }
            column(VendorNo; "Vendor No.") { }
            column(VendorName; VendorName) { }
            column(DateFilter; DateFilter) { }
            column(Division; Division) { }
            column(DivisionName; DivisionName) { }
            column(Product_Group; "Product Group") { }
            column(Product_Group_Description; "Product Group Description") { }
            column(Date; Date) { }
            column(costTax; "costTax")
            {
            }
            // column(LineDiscount; "Line Discount")
            // {
            // }
            // column(LineNo; "Line No.")
            // {
            // }
            // column(NetAmount; "Net Amount")
            // {
            // }
            // column(NetPrice; "Net Price")
            // {
            // }
            // column(POSTerminalNo; "POS Terminal No.")
            // {
            // }
            // column(Price; Price)
            // {
            // }
            // column(PriceGroupCode; "Price Group Code")
            // {
            // }
            // column(StoreNo; "Store No.")
            // {
            // }
            // column(StatementCode; "Statement Code")
            // {
            // }

            trigger OnPreDataItem()
            begin
                DateFilter := ce.GetFilter(Date);
                StoreFilter := ce.GetFilter("Store No.");
                DivisionFilter := ce.GetFilter(Division);
                RPGFilter := ce.GetFilter("Product Group");
                BrandFilter := ce.GetFilter("Special Group");

                ce.SetFilter("Document No.", '<>%1', '');
            end;

            trigger OnAfterGetRecord()
            var
                LRecStore: Record "LSC Store";
                LRecVendor: Record "Vendor";
                lrecBrand: Record "LSC Item Special Groups";
                lrecdiv: Record "LSC Division";
            begin
                CostRatePctg := round(100 - "Consignment %", 0.01);
                costprice := "Total Excl Tax" - "Consignment Amount"; //Total - profit amount
                costTax := costprice * ("Tax Rate" / 100); //Total - profit amount
                clear(LRecStore);
                if LRecStore.Get("Store No.") then
                    StoreName := LRecStore.Name;

                clear(lrecvendor);
                if LRecVendor.get("Vendor No.") then
                    VendorName := LRecVendor.Name;

                clear(lrecBrand);
                if lrecBrand.Get("Special Group") then
                    BrandName := lrecBrand.Description;

                clear(lrecdiv);
                if lrecdiv.get(Division) then
                    DivisionName := lrecdiv.Description;
            end;
        }
        */
    }

    // requestpage
    // {
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(Group)
    //             {
    //                 field("Date"; ce.Date) { }
    //                 field("Store No."; ce."Store No.") { }
    //                 field("Division"; ce.Division) { }
    //                 field("Retail Product Group"; ce."Product Group") { }
    //                 field("Special Group Code (Brand)"; ce."Special Group") { }
    //             }
    //         }
    //     }
    //     // actions
    //     // {
    //     //     area(Processing)
    //     //     {
    //     //     }
    //     // }
    // }
    var
        costratepctg: Decimal;
        costprice: Decimal;
        DateFilter: text;
        StoreFilter: text;
        DivisionFilter: text;
        RPGFilter: text;
        BrandFilter: text;
        StoreName: text;
        VendorName: text;
        BrandName: text;
        DivisionName: text;
        costTax: Decimal;
}

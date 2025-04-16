report 70011 "Consignment Purchase"
{
    ApplicationArea = All;
    Caption = 'Consignment Purchase Report';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70011.ConsignmentPurchase.rdl';
    dataset
    {
        dataitem(CE; "Consignment Entries")
        {
            RequestFilterFields = "Billing Period ID", "Store No.", Division, "Product Group", "Special Group";
            column(Brand; "Special Group") { }
            column(BrandName; BrandName) { }
            column(Quantity; Quantity) { }
            column(SalesPrice; "Total Incl Tax") { }
            column(CostPrice; CostPrice) { }
            column(VATCode; "VAT Code") { }
            column(TaxRate; "Tax Rate") { }
            column(Tax; "Tax") { }
            column(ItemNo; "Item No.") { }
            column(Description; "Item Description") { }
            column(SalesAmount; "Total Incl Tax") { }
            column(TotalExclTax; "Total Excl Tax") { }
            column(Cost; "Cost") { }
            column(Store_No_; "Store No.") { }
            column(StoreName; StoreName) { }
            column(VendorNo; "Vendor No.") { }
            column(VendorName; VendorName) { }
            column(FromDateFilter; FromDateFilter) { }
            column(ToDateFilter; ToDateFilter) { }
            column(Division; Division) { }
            column(DivisionName; DivisionName) { }
            column(Product_Group; "Product Group") { }
            column(Product_Group_Description; "Product Group Description") { }
            column(Date; Date) { }
            column(VAT_Amount; "VAT Amount") { }
            column(Tax_Rate; "Tax Rate") { }

            trigger OnPreDataItem()
            begin
                PeriodsFilter := ce.GetFilter("Billing Period ID");
                StoreFilter := ce.GetFilter("Store No.");
                DivisionFilter := ce.GetFilter(Division);
                RPGFilter := ce.GetFilter("Product Group");
                BrandFilter := ce.GetFilter("Special Group");

                IF (PeriodsFilter = '') THEN
                    ERROR('The report couldn’t be generated, because it was empty. Input data for the Period field.');
            end;

            trigger OnAfterGetRecord()
            var
                LRecStore: Record "LSC Store";
                LRecVendor: Record "Vendor";
                lrecBrand: Record "LSC Item Special Groups";
                lrecdiv: Record "LSC Division";
            begin
                CostRatePctg := round(100 - "Consignment %", 0.01);
                costprice := "Total Excl Tax" * "Consignment %";
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

                Clear(RecPeriods);
                RecPeriods.SetRange("ID", ce."Billing Period ID");
                if RecPeriods.FindFirst() then begin
                    FromDateFilter := RecPeriods."Start Date";
                    ToDateFilter := RecPeriods."End Date";
                end;
            end;
        }
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
        RecPeriods: Record "WP B.Inc Billing Periods";
        costratepctg: Decimal;
        costprice: Decimal;
        PeriodsFilter: text;
        FromDateFilter: Date;
        ToDateFilter: Date;
        StoreFilter: text;
        DivisionFilter: text;
        RPGFilter: text;
        BrandFilter: text;
        StoreName: text;
        VendorName: text;
        BrandName: text;
        DivisionName: text;
}

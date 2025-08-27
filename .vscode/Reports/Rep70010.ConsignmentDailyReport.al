report 70010 "Consignment Daily Report"
{
    ApplicationArea = All;
    Caption = 'Consignment Daily Report';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70010.WPConsignmentDailyReport.rdl';
    dataset
    {
        dataitem(CE; "Daily Consign. Sales Details")
        {
            DataItemTableView = sorting("Date", "Vendor No.");

            column(Division; "Division") { }
            column(DivisionName; "DivisionName") { }
            column(StoreName; "StoreName") { }
            column(Store_No_; "Store No.") { }
            column(Date; "Date") { }
            column(Vendor_No_; "Vendor No.") { }
            column(Vendor_Name; "VendorName") { }
            column(Class; "Product Group") { }
            column(ClassName; "Product Group Description") { }
            column(Brand; "Special Group") { }
            column(BrandName; "Special Group Description") { }
            column(Type; "Type") { }
            column(Transaction_No_; "Transaction No.") { }
            column(Receipt_No; "Receipt No.") { }
            column("Sale_Excl_Tax"; "Total Excl Tax") { }
            column("Cost_Excl_Tax"; "Cost") { }
            column(CostRate; CostRatePctg) { }
            column(TaxRate; TaxRate) { }
            column(Tax; costTax) { }
            column(Quantity; Quantity) { }
            column(Profit__; "Profit %") { }
            column(Item_No_; "Item No.") { }
            column(Item_Description; "Item Description") { }

            trigger OnPreDataItem()
            begin
                if DateFilter = '' then
                    error('Input DateFilter!');

                ce.SetFilter("Date", DateFilter);
                if StoreFilter <> '' then ce.SetRange("Store No.", StoreFilter);
                if DivisionFilter <> '' then ce.SetRange("Division", DivisionFilter);
                if VendorFilter <> '' then ce.SetRange("Vendor No.", VendorFilter);
                if BrandFilter <> '' then ce.SetRange("Special Group", BrandFilter);
                if RPGFilter <> '' then ce.SetRange("Product Group", RPGFilter);
                if ItemCategoryFilter <> '' then ce.SetRange("Item Category", ItemCategoryFilter);
            end;

            trigger OnAfterGetRecord()
            var
                LRecStore: Record "LSC Store";
                LRecVendor: Record "Vendor";
                lrecBrand: Record "LSC Item Special Groups";
                lrecdiv: Record "LSC Division";
                tbVatPosting: Record "VAT Posting Setup";
                tbItem: Record "Item";
            begin
                CostRatePctg := round(100 - "Profit %", 0.01);

                clear(tbItem);
                tbItem.SetRange("No.", ce."Item No.");
                tbItem.FindFirst();

                "Item Description" := tbItem.Description;

                Clear(tbVatPosting);// Record "VAT Posting Setup";
                tbVatPosting.SetRange("VAT Prod. Posting Group", tbItem."VAT Prod. Posting Group");
                tbVatPosting.SetRange("VAT Bus. Posting Group", 'DOMESTIC_IN');
                if tbVatPosting.FindFirst() then begin
                    TaxRate := tbVatPosting."VAT %";
                end else
                    TaxRate := 0;

                costTax := Cost * ("Tax Rate" / 100); //Total - profit amount

                clear(LRecStore);
                if LRecStore.Get("Store No.") then
                    StoreName := LRecStore.Name;

                "Type" := 'Cons Purchase';

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


    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Group)
                {
                    field("Date"; DateFilter)
                    {
                        trigger OnValidate()
                        begin
                            ApplicationManagement.MakeDateFilter(DateFilter);
                        end;
                    }
                    field("Store No."; StoreFilter)
                    {
                        TableRelation = "LSC Store"."No.";
                    }
                    field("Vendor"; VendorFilter)
                    {
                        TableRelation = "Vendor"."No.";
                    }
                    field("Division"; DivisionFilter)
                    {
                        TableRelation = "LSC Division".Code;
                    }
                    field("Special Group Code (Brand)"; BrandFilter)
                    {
                        TableRelation = "LSC Item Special Groups".Code;
                    }
                    field("Item Category"; ItemCategoryFilter)
                    {
                        TableRelation = "Item Category".Code;
                    }
                    field("Retail Product Group (Class)"; RPGFilter)
                    {
                        TableRelation = "LSC Retail Product Group".Code;
                    }
                }
            }
        }
    }

    var
        costratepctg: Decimal;
        costprice: Decimal;
        DateFilter: text;
        StoreFilter: text;
        DivisionFilter: text;
        RPGFilter: text;
        BrandFilter: text;
        VendorFilter: text;
        StoreName: text;
        VendorName: text;
        BrandName: text;
        DivisionName: text;
        Type: text;
        costTax: Decimal;
        TaxRate: Decimal;
        Tax: Decimal;
        ItemCategoryFilter: Text;
        ApplicationManagement: Codeunit "Filter Tokens";
}

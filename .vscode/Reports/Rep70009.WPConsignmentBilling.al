report 70009 "WP Consignment Billing"
{
    ApplicationArea = All;
    Caption = 'Consignment Billing Report';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70009.WPConsignmentBilling.rdl';

    dataset
    {
        dataitem(ConsignmentEntries; "Consignment Billing Entries")

        {
            RequestFilterFields = "Sales Date", "Store No.", "Product Group", "Special Group";
            column(ConsignmentAmount; "Total Excl Tax") { }
            //column(ConsignmentType; "Consignment Type") { }
            column(Cost; "Consignment %") { }
            //column(CostAmount; "Cost Amount") { }
            column(Date; "Sales Date") { }
            //column(Division; Division) { }
            //column(DocumentNo; "Document No.") { }
            //column(ItemCategory; "Product Group") { }
            //column(NetAmount; "Net Amount") { }
            //column(NetPriceExclTax; "Net Price Excl Tax") { }
            column(Price; "Total Excl Tax") { }
            column(ProductGroup; "Product Group") { }
            column(ProductGroupDesc; "Product Group Description") { }
            column(Quantity; Quantity) { }
            column(SpecialGroup; "Special Group") { }
            //column(SpecialGroup2; "Special Group 2") { }
            //column(Tax; Tax) { }
            column(TaxRate; gTaxRate) { }
            column(VATAmount; "Total Tax") { }
            column(VendorNo; "Vendor No.") { }
            column(Special_Group_Description; "Special Group Description") { }
            //column(Special_Group_2_Description; "Special Group 2 Description") { }
            column(VendorName; VendorName) { }
            //column(VendorFilter; VendorFilter) { }
            //column(DateFilter; DateFilter) { }
            //column(ItemCategoryFilter; ItemCategoryFilter) { }
            column(TotalCost; TotalCost) { }
            column(Total_Excl_Tax; Cost) { }
            column(Total_Incl_Tax; "Total Tax" + "Cost") { }
            //column(ClassFilter; ClassFilter) { }
            //column(Trans; "Receipt No.") { }

            trigger OnPreDataItem()
            begin
                //VendorFilter := ConsignmentEntries.GetFilter("Vendor No.");
                //DateFilter := ConsignmentEntries.GetFilter(Date);
                //ItemCategoryFilter := ConsignmentEntries.GetFilter("Item Category");
                //classfilter := ConsignmentEntries.GetFilter("Product Group");
            end;

            trigger OnAfterGetRecord()
            var
                LRecVen: Record vendor;
                LRecVAT: record "VAT Posting Setup";
            begin
                ConsignmentEntries.CalcFields("Special Group Description", "Special Group 2 Description");
                if LRecVen.Get(ConsignmentEntries."Vendor No.") then
                    VendorName := LRecVen.Name;
                TotalCost := ConsignmentEntries."Total Incl Tax";

                clear(LRecVAT);
                if LRecVAT.get(lrecven."VAT Bus. Posting Group", "VAT Code") then
                    gtaxrate := LRecVAT."VAT %"
                else
                    gtaxrate := 0;

            end;
        }
    }

    requestpage
    {
        // layout
        // {
        //     area(Content)
        //     {
        //         group(GroupName)
        //         {
        //             field("Date"; ConsignmentEntries.Date) { }
        //             field("Store No."; ConsignmentEntries."Store No.") { }
        //             field("Division"; ConsignmentEntries.Division) { }
        //             field("Retail Product Group"; ConsignmentEntries."Product Group") { }
        //             field("Special Group Code (Brand)"; ConsignmentEntries."Special Group") { }
        //         }
        //     }
        // }
    }
    var
        //VendorFilter: Text;
        //DateFilter: Text;
        //ItemCategoryFilter: Text;
        VendorName: text;
        TotalCost: decimal;
        //classfilter: text;
        gtaxrate: decimal;
}

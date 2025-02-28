report 70001 "Consignment Report"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70001.ConsignmentReport.rdl';

    dataset
    {
        dataitem("Consignment Entries"; "Consignment Entries")
        {
            column(ItemNo; "Item No.") { }
            column(ItemDescription; "Item Description") { }
            column(Date; Date) { }
            column(Store; "Store No.") { }
            column(Vendor; "Vendor No.") { }
            column(Division; Division) { }
            column(ItemCategory; "Item Category") { }
            column(ProductGroup; "Product Group") { }
            column(SpecialGroup; "Special Group") { }
            column(Quantity; Quantity) { }
            column(Price; Price) { }
            column(UOM; UOM) { }
            column(NetAmount; "Net Amount") { }
            column(VATAmount; "VAT Amount") { }
            column(Discount_Amount; "Discount Amount") { }
            column(PromotionNo; "Promotion No.") { }
            column(PeriodicDiscType; "Periodic Disc. Type") { }
            column(PeriodicOfferNo; "Periodic Offer No.") { }
            column(PeriodicDiscountAmount; "Periodic Discount Amount") { }
            column(VATCode; "VAT Code") { }
            column(ReturnNoSales; "Return No Sales") { }
            column(ConsignmentType; "Consignment Type") { }
            column(ConsignmentPerc; "Consignment %") { }
            column(ConsignmentAmount; "Consignment Amount") { }
            column(StoreName; recStore.Name) { }
            column(ConsignDesc; recConsignType.Description) { }
            column(CompanyPicture; recCompanyInfo.Picture) { }
            column(VendName; recVend.Name) { }
            column(VendAddr1; VendAddr[1]) { }
            column(VendAddr2; VendAddr[2]) { }
            column(VendAddr3; VendAddr[3]) { }
            column(VendAddr4; VendAddr[4]) { }
            column(VendAddr5; VendAddr[5]) { }
            column(VendAddr6; VendAddr[6]) { }
            column(CompanyAddr1; CompanyAddr[1]) { }
            column(CompanyAddr2; CompanyAddr[2]) { }
            column(CompanyAddr3; CompanyAddr[3]) { }
            column(CompanyAddr4; CompanyAddr[4]) { }
            column(CompanyAddr5; CompanyAddr[5]) { }
            column(CompanyInforPhNo; recCompanyInfo."Phone No.") { }
            column(CompanyInfoVatRegNo; recCompanyInfo."VAT Registration No.") { }
            column(Disc__Amount_From_Std__Price; "Disc. Amount From Std. Price") { }
            column(Net_Price_Incl_Tax; "Net Price Incl Tax") { }
            column(Total_Incl_Tax; "Total Incl Tax") { }
            column(Tax; Tax) { }
            column(Total_Tax_Collected; "Total Tax Collected") { }
            column(Net_Price_Excl_Tax; "Net Price Excl Tax") { }
            column(Total_Excl_Tax; "Total Excl Tax") { }
            column(DateFilter; DateFilter) { }
            column(Gross_Price; "Gross Price") { }

            trigger OnPreDataItem()
            begin
                datefilter := "Consignment Entries".GetFilter(Date);
            end;

            trigger OnAfterGetRecord()
            begin
                CLEAR(recConsignType);
                recConsignType.RESET;
                recConsignType.SETRANGE(Code, "Consignment Entries"."Consignment Type");
                IF recConsignType.FINDFIRST THEN;

                CLEAR(recStore);
                recStore.RESET;
                IF recStore.GET("Consignment Entries"."Store No.") THEN;

                CLEAR(recVend);
                IF recVend.GET("Consignment Entries"."Vendor No.") THEN;

                FormatAddr.GetCompanyAddr(recCompanyInfo."Responsibility Center", RespCenter, recCompanyInfo, CompanyAddr);
                FormatAddr.Vendor(VendAddr, recVend);
            end;
        }
    }

    trigger OnPreReport()
    begin
        recCompanyInfo.GET;
        recCompanyInfo.CALCFIELDS(Picture);
    end;

    var
        RespCenter: Record "Responsibility Center";
        recStore: Record "LSC Store";
        recConsignType: Record "Consignment Type";
        recCompanyInfo: Record "Company Information";
        recVend: Record Vendor;
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array[10] of Text[50];
        VendAddr: array[10] of Text[50];
        DateFilter: text[250];
}
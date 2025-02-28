report 70003 "Consignment Sales Report"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70003.ConsignmentSalesReport.rdl';

    dataset
    {

        dataitem("Consignment Entries"; "Consignment Entries")
        {
            RequestFilterFields = "date", "Store No.", "Vendor No.", "Item Family Code", "Division", "Item Category", "Product Group";
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
            column(LDateFor; LDateFor) { }
            column(DepartmentDesc; gDIDesc) { }
            column(SubDeptDesc; gICDesc) { }
            column(DivisionDesc; gIFDesc) { }
            column(CategoryDesc; gRPDesc) { }
            column(DivisionCode; "Item Family Code") { }

            trigger OnPreDataItem()
            begin
                datefilter := "Consignment Entries".GetFilter(Date);
            end;

            trigger OnAfterGetRecord()
            begin
                recConsignType.Reset();
                recConsignType.SetRange(Code, "Consignment Entries"."Consignment Type");
                if recConsignType.FindFirst() then;

                recStore.Reset();
                if recStore.Get("Consignment Entries"."Store No.") then;

                recVend.Reset();
                if recVend.Get("Consignment Entries"."Vendor No.") then;

                FormatAddr.GetCompanyAddr(recCompanyInfo."Responsibility Center", RespCenter, recCompanyInfo, CompanyAddr);
                FormatAddr.Vendor(VendAddr, recVend);

                LDateFor := Format(Date, 0, '<Year4>-<Month,2>');

                clear(gIFDesc);
                ItemFamily.Reset();
                ItemFamily.SetRange(Code, "Item Family Code");
                ItemFamily.SetLoadFields(Description);
                if ItemFamily.FindFirst() then
                    gIFDesc := ItemFamily.Description;

                clear(gDIDesc);
                Divison.Reset();
                Divison.SetRange(code, Division);
                Divison.SetLoadFields(Description);
                if Divison.FindFirst() then
                    gDIDesc := Divison.Description;

                clear(gicdesc);
                ItemCategory.Reset();
                ItemCategory.SetRange(Code, "Item Category");
                ItemCategory.SetLoadFields(Description);
                if ItemCategory.FindFirst() then
                    gICDesc := ItemCategory.Description;

                clear(grpdesc);
                RetailProductGroup.Reset();
                RetailProductGroup.SetRange(Code, "Product Group");
                RetailProductGroup.SetLoadFields(Description);
                if RetailProductGroup.FindFirst() then
                    gRPDesc := RetailProductGroup.Description;
            end;
        }

    }

    trigger OnPreReport()
    begin
        if recCompanyInfo.Get() then;
        recCompanyInfo.CALCFIELDS(Picture);
    end;

    var
        RetailProductGroup: Record "lSC Retail Product Group";
        RespCenter: Record "Responsibility Center";
        recConsignType: Record "Consignment Type";
        recCompanyInfo: Record "Company Information";
        recStore: Record "LSC Store";
        ItemFamily: Record "LSC Item Family";
        recVend: Record Vendor;
        Divison: Record "LSC Division";
        ItemCategory: Record "Item Category";
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array[10] of Text[50];
        VendAddr: array[10] of Text[50];
        DateFilter: text[250];
        LDateFor: text[7];
        gIFDesc: text[50];
        gDIDesc: text[50];
        gICDesc: text[50];
        gRPDesc: text[50];
}
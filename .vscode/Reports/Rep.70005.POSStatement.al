report 70005 "POS Statement Report"
{
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    RDLCLayout = '.vscode\ReportLayouts\\Rep.70005.POSStatementReport.rdl';

    dataset
    {
        dataitem(ConsignmentHeader; "Consignment Header")
        {
            DataItemTableView = sorting("Document No.");
            RequestFilterFields = "Document No.", "Vendor No.", "Start Date", "End Date", Status;

            column(CompanyLogo; recCompanyInfo.Picture) { }
            column(CompanyName; recCompanyInfo.Name) { }
            column(CompanyRegNo; recCompanyInfo."Registration No.") { }
            column(CompanyAddress; recCompanyInfo.Address) { }
            column(CompanyPostCode; recCompanyInfo."Post Code") { }
            column(CompanyCity; recCompanyInfo.City) { }
            column(CompanyCountry; recCompanyInfo."Country/Region Code") { }
            column(CompanyPhoneNo; recCompanyInfo."Phone No.") { }
            column(CompanyFaxNo; recCompanyInfo."Fax No.") { }
            //column(CompanyWebSite; recCompanyInfo."Home Page") { }
            column(CompanyWebSite; '') { }
            column(CompanyVATRegNo; recCompanyInfo."VAT Registration No.") { }
            column(VendorName; recVend.Name) { }
            column(VendorAddress; recVend.Address) { }
            column(VendorAddress2; recVend."Address 2") { }
            column(VendorPostCode; recVend."Post Code") { }
            column(VendorCity; recVend.City) { }
            column(VendorCountry; recVend."Country/Region Code") { }
            column(VendorNo; recVend."No.") { }
            column(VendorVATRegNo; recVend."VAT Registration No.") { }
            column(CHEndDate; ConsignmentHeader."End Date") { }
            column(CHDocumentDate; ConsignmentHeader."Document Date") { }

            dataitem("ConsignmentBillingEntries"; "Consignment Billing Entries")
            {
                DataItemTableView = sorting("Document No.", "Line No.");
                DataItemLink = "Document No." = field("Document No.");

                column(CBELineDate; ConsignmentHeader."Document Date") { }
                column(CBEStoreNo; ConsignmentBillingEntries."Store No.") { }
                column(CBEArticleClass; gArticleClass) { }
                column(CBESD; ConsignmentBillingEntries."Consignment %") { }
                column(CBESalesAmount; ConsignmentBillingEntries."Total Excl Tax") { }
                column(CBESSTAmount; ConsignmentBillingEntries."Total Tax") { }
                column(CBEMargin; ConsignmentBillingEntries.Profit) { }
                column(CBENetAmount; ConsignmentBillingEntries.Cost) { }

                trigger OnAfterGetRecord()
                var
                    RecSG: Record "LSC Item Special Groups";
                begin
                    ConsignmentBillingEntries.CalcFields("Special Group Description", "Product Group Description");
                    if ConsignmentBillingEntries."Special Group" <> '' then
                        gArticleClass := ConsignmentBillingEntries."Special Group Description" + '-' + ConsignmentBillingEntries."Product Group Description"
                    else
                        gArticleClass := ConsignmentBillingEntries."Product Group Description";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                recVend.Reset();
                if recVend.GET(ConsignmentHeader."Vendor No.") then;

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
        FormatAddr: Codeunit "Format Address";
        recCompanyInfo: Record "Company Information";
        recVend: Record Vendor;
        CompanyAddr: array[10] of Text[50];
        VendAddr: array[10] of Text[50];
        RespCenter: Record "Responsibility Center";
        gArticleClass: Text;
}
report 70002 "Consignment E-Mail Body"
{
    DefaultLayout = Word;
    WordLayout = '.vscode\ReportLayouts\\Rep.70002.ConsignmentEmailBody.docx';
    dataset
    {
        dataitem("Consignment Process Log"; "Consignment Process Log")
        {
            column(Vendor_No_; "Vendor No.") { }
            column(Purchase_Invoice_No_; "Purchase Invoice No.") { }
            column(Sales_Invoice_No_; "Sales Invoice No.") { }
            column(Starting_Date; "Starting Date") { }
            column(Ending_Date; "Ending Date") { }
            column(Customer_No_; "Customer No.") { }
            column(VendorName; VendorName) { }
            trigger OnAfterGetRecord();
            var
                Vendor: Record vendor;
            begin
                Vendor.Reset();
                Vendor.SetLoadFields(Name);
                if Vendor.Get("Vendor No.") then
                    VendorName := Vendor.Name;
            end;
        }
    }
    var
        VendorName: Text[100];
}

pageextension 58066 RetailVendorList extends "LSC Retail Vendor List"
{
    layout
    {
        addafter("Buyer Group Code")
        {
            field("E-Mail"; Rec."E-Mail") { ApplicationArea = All; }
            field("Is Consignment Vendor"; Rec."Is Consignment Vendor") { ApplicationArea = All; }
            field("Linked Customer No."; Rec."Linked Customer No.") { ApplicationArea = All; }
            field("Consign. Start Date"; Rec."Consign. Start Date") { ApplicationArea = All; }
            field("Consign. End Date"; Rec."Consign. End Date") { ApplicationArea = All; }
        }
    }
}
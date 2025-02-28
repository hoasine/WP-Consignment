pageextension 70001 VendorList extends "Vendor List"
{
    layout
    {

        addafter("Payments (LCY)")
        {
            field("E-Mail"; Rec."E-Mail") { ApplicationArea = All; }
            field("Is Consignment Vendor"; Rec."Is Consignment Vendor") { ApplicationArea = All; }
            field("Linked Customer No."; Rec."Linked Customer No.") { ApplicationArea = All; }
            field("Consign. Start Date"; Rec."Consign. Start Date") { ApplicationArea = All; }
            field("Consign. End Date"; Rec."Consign. End Date") { ApplicationArea = All; }
        }
    }
}

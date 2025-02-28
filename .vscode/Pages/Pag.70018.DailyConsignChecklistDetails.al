page 70018 "Daily Consign Checklist Det."
{
    Caption = 'Daily Consignment Checklist Details';
    PageType = ListPart;
    SourceTable = "Daily Consign. Sales Details";
    ShowFilter = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Date"; Rec."Date") { ApplicationArea = All; }
                field("Store No."; Rec."Store No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Division; Rec.Division) { ApplicationArea = All; }
                field("Item Category"; Rec."Item Category") { ApplicationArea = All; }
                field("Item Category Description"; Rec."Item Category Description") { ApplicationArea = All; }
                field("Product Group"; Rec."Product Group") { ApplicationArea = All; }
                field("Product Group Description"; Rec."Product Group Description") { ApplicationArea = All; }
                field("Special Group"; Rec."Special Group") { ApplicationArea = All; }
                field("Special Group Description"; Rec."Special Group Description") { ApplicationArea = All; }
                field("Special Group 2"; Rec."Special Group 2") { ApplicationArea = All; }
                field("Special Group 2 Description"; Rec."Special Group 2 Description") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field("Item Description"; Rec."Item Description") { ApplicationArea = All; }
                field("Promotion No."; Rec."Promotion No.") { ApplicationArea = All; }
                field("Periodic Disc. Type"; Rec."Periodic Disc. Type") { ApplicationArea = All; }
                field("Periodic Offer No."; Rec."Periodic Offer No.") { ApplicationArea = All; }
                field("Total Discount"; Rec."Total Discount") { ApplicationArea = All; }
                field("Total Discount Desc"; Rec."Total Discount Desc") { ApplicationArea = All; }
                field("Discount Amount"; Rec."Discount Amount") { ApplicationArea = All; }
                field("Total Excl Tax"; Rec."Total Excl Tax") { ApplicationArea = All; }
                field("VAT Amount"; Rec."VAT Amount") { ApplicationArea = All; }
                field("Total Incl Tax"; Rec."Total Incl Tax") { ApplicationArea = All; }
                field("Consignment Type"; Rec."Consignment Type") { ApplicationArea = All; }
                field("Consignment %"; Rec."Consignment %") { ApplicationArea = All; }
            }
        }
    }
}
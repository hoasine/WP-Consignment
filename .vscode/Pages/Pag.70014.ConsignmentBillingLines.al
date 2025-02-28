page 70014 "Consignment Billing Lines"
{
    Caption = 'Consignment Billing Lines';
    PageType = List;
    //UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Consignment Billing Entries";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Billing Type"; Rec."Billing Type") { }
                field("Store No."; Rec."Store No.") { }
                field("Vendor No."; Rec."Vendor No.") { }
                field("Product Group"; Rec."Product Group") { }
                field("Product Group Description"; Rec."Product Group Description") { }
                field("Special Group"; Rec."Special Group") { }
                field("Special Group Description"; Rec."Special Group Description") { }
                field("Special Group 2"; Rec."Special Group 2") { }
                field("Special Group 2 Description"; Rec."Special Group 2 Description") { }
                field("Consignment %"; Rec."Consignment %") { }
                field("VAT Code"; Rec."VAT Code") { }
                field("Total Excl Tax"; Rec."Total Excl Tax") { }
                field("Total Incl Tax"; Rec."Total Incl Tax") { }
                field("Total Tax"; Rec."Total Tax") { }
                field(Cost; Rec.Cost) { }
                field(Profit; Rec.Profit) { }

            }
        }
    }
}
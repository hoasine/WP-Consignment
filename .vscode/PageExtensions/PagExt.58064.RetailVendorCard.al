pageextension 58064 RetailVendorCard extends "LSC Retail Vendor Card"
{
    layout
    {
        addafter("Foreign Trade")
        {
            // part("Consignment Rate"; "Consignment Rate")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Consignment Rate';
            //     SubPageLink = "Vendor No." = field("No.");
            // }

            // part("Consignment Setup"; "Consignment Setup")
            // {
            //     SubPageLink = "Vendor No." = field("No.");
            //     ShowFilter = true;
            //     ApplicationArea = All;
            // }
            group("Consignment & Buying Income Setup")
            {
                field("Is Consignment Vendor"; rec."Is Consignment Vendor")
                {
                    ApplicationArea = all;
                    caption = 'Is Consignment Vendor';
                    Description = 'Is Consignment Vendor';
                }
                field("Linked Customer No."; Rec."Linked Customer No.")
                {
                    ApplicationArea = all;
                    Caption = 'Linked Customer No.';
                    Description = 'Linked Customer No.';
                }
                field("Consign. Start Date"; rec."Consign. Start Date")
                {
                    ApplicationArea = all;
                    caption = 'Consign. Start Date';
                    Description = 'Consign. Start Date';
                    Editable = rec."Is Consignment Vendor";
                }
                field("Consign. End Date"; rec."Consign. End Date")
                {
                    ApplicationArea = all;
                    caption = 'Consign. End Date';
                    Description = 'Consign. End Date';
                    Editable = rec."Is Consignment Vendor";
                }
            }

        }
    }
}
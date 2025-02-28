pageextension 70000 "Vendor Card Extension" extends "Vendor Card"
{
    layout
    {
        // addafter(Receiving)
        // {
        //     part("Consignment Rate"; "Consignment Rate") { ApplicationArea = all; SubPageLink = "Vendor No." = field("No."); Visible = false; }
        // }
        // addafter("Consignment Rate")
        // {
        //     part("Consignment Setup"; "Consignment Setup") { ApplicationArea = all; SubPageLink = "Vendor No." = field("No."); ShowFilter = true; Visible = false; }
        // }
        addafter("Receiving")
        {
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
                field("Consign. Billing Frequency"; rec."Consign. Billing Frequency")
                {
                    ApplicationArea = all;
                    caption = 'Consign. Billing Frequency';
                    Description = 'Consign. Billing Frequency';
                    Editable = rec."Is Consignment Vendor";
                }
                field("Daily Sales E-Mail"; rec."Daily Sales E-Mail")
                {
                    ApplicationArea = all;
                    caption = 'Daily Sales E-Mail';
                    Description = 'Daily Sales E-Mail';
                    Editable = rec."Is Consignment Vendor";
                }
            }
            part("Minimum Profit Guarantee"; "WP Minimum Profit Guarantee") { ApplicationArea = all; SubPageLink = "Vendor No." = field("No."); }
            part("Counter Area"; "WP counter area") { ApplicationArea = all; SubPageLink = "Vendor No." = field("No."); }
            part("Consignment Margin Setup"; "WP Consignment Margin Setup") { ApplicationArea = all; SubPageLink = "Vendor No." = field("No."); }
        }
    }
}
page 70010 "Consignment Billing Entries"
{
    Caption = 'Consignment Billing Entries';
    PageType = ListPart;
    SourceTable = "Consignment Billing Entries";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Billing Type"; Rec."Billing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Billing Type field.';
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("Sales Date"; Rec."Sales Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Date field.';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract ID field.';
                }
                field("Billing Period ID"; Rec."Billing Period ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Billing Period ID field.';
                }
                field("Expected Gross Profit"; Rec."Expected Gross Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expected Gross Profit field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Product Group"; Rec."Product Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Product Group field.';
                }
                field("Product Group Description"; Rec."Product Group Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Product Group Description field.';
                }

                field("Special Group"; Rec."Special Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Special Group field.';
                }
                field("Special Group Description"; Rec."Special Group Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Special Group Description field.';
                }
                //20240513-
                field("Special Group 2"; Rec."Special Group 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Special Group field.';
                }
                field("Special Group 2 Description"; Rec."Special Group 2 Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Special Group Description field.';
                }
                //20240513+
                field("Consignment %"; Rec."Consignment %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Consignment % field.';
                }
                field("VAT Code"; Rec."VAT Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Code field.';
                }

                field("Total Incl Tax"; Rec."Total Incl Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Incl Tax field.';
                    Caption = 'Sales Incl Tax';
                }
                field("Total Tax"; Rec."Total Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Tax field.';
                    Caption = 'Sales Tax';
                }

                field("Total Excl Tax"; Rec."Total Excl Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Excl Tax field.';
                    Caption = 'Sales Excl Tax';
                }

                field(Cost; Rec.Cost)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost field.';
                    Caption = 'Cost Excl Tax';
                }
                field("Cost Vat Tax"; GetCostInclVAT())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the cost Vat Tax field.';
                    Caption = 'Cost Vat Tax';
                }
                field("Cost Incl Tax"; Rec."Cost Incl Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the cost incl Tax field.';
                    Caption = 'Cost Incl Tax';
                }


                field(Profit; Rec.Profit)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit field.';
                }
            }
        }
    }
    local procedure GetCostInclVAT(): Decimal

    begin
        exit(Rec."Cost Incl Tax" - Rec.Cost);
    end;
}

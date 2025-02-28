page 70023 "WP Minimum Profit Guarantee"
{
    ApplicationArea = All;
    Caption = 'Minimum Profit Guarantee';
    PageType = ListPart;
    SourceTable = "WP MPG Setup";
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ToolTip = 'Specifies the value of the Contract ID field.', Comment = '%';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the value of the Contract Type field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("Billing Period ID"; Rec."Billing Period ID")
                {
                    ToolTip = 'Specifies the value of the Billing Period ID field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                }
                field("Expected Gross Profit"; Rec."Expected Gross Profit")
                {
                    ToolTip = 'Specifies the value of the Expected Gross Profit field.', Comment = '%';
                }
            }
        }
    }
}

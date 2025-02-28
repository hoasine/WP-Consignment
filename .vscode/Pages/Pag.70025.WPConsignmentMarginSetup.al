page 70025 "WP Consignment Margin Setup"
{
    ApplicationArea = All;
    Caption = 'Consignment Margin Setup';
    PageType = ListPart;
    SourceTable = "WP Consignment Margin Setup";
    DelayedInsert = false;
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
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ToolTip = 'Specifies the value of the Contract ID field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                }
                field("Disc. From"; Rec."Disc. From")
                {
                    ToolTip = 'Specifies the value of the Disc. From field.', Comment = '%';
                }
                field("Disc. To"; Rec."Disc. To")
                {
                    ToolTip = 'Specifies the value of the Disc. To field.', Comment = '%';
                }
                field("Profit Margin"; Rec."Profit Margin")
                {
                    ToolTip = 'Specifies the value of the Profit Margin field.', Comment = '%';
                }
            }
        }
    }
}

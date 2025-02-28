page 70024 "WP Counter Area"
{
    ApplicationArea = All;
    Caption = 'Counter Area';
    PageType = ListPart;
    SourceTable = "WP Counter Area";
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
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                }
                field("Store Description"; Rec."Store Description")
                {
                    ToolTip = 'Specifies the value of the Store Description field.', Comment = '%';
                }
                field("Contract ID"; Rec."Contract ID")
                {
                    ToolTip = 'Specifies the value of the Contract ID field.', Comment = '%';
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ToolTip = 'Specifies the value of the Contract Description field.', Comment = '%';
                }
                field("Location ID"; Rec."Location ID")
                {
                    ToolTip = 'Specifies the value of the Location ID field.', Comment = '%';
                }
                field(Floor; Rec.Floor)
                {
                    ToolTip = 'Specifies the value of the Floor field.', Comment = '%';
                }
                field(Brand; Rec.Brand)
                {
                    ToolTip = 'Specifies the value of the Brand field.', Comment = '%';
                }
                field("Area"; Rec."Area")
                {
                    ToolTip = 'Specifies the value of the Area field.', Comment = '%';
                }
            }
        }
    }
}

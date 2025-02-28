page 70026 "WP Billing Periods"
{
    ApplicationArea = All;
    Caption = 'Consignment Billing Periods';
    PageType = List;
    SourceTable = "WP B.Inc Billing Periods";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field.', Comment = '%';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                }
                field("Billing Cut-Off Date"; Rec."Billing Cut-Off Date")
                {
                    ToolTip = 'Specifies the value of the Billing Cut-Off Date field.', Comment = '%';
                }
                field("Consignment Billing Type"; Rec."Consignment Billing Type")
                {
                    ToolTip = 'Specifies the value of the Consignment Billing Type field.', Comment = '%';
                }
                field("Period Type"; Rec."Period Type")
                {
                    ToolTip = 'Specifies the value of the Period Type field.', Comment = '%';
                }
                field("Confirm Email"; Rec."Confirm Email")
                {
                    ToolTip = 'Specifies the value of the Confirm Email field.', Comment = '%';
                }
                field("Batch Is Done"; Rec."Batch Is Done")
                {
                    ToolTip = 'Specifies the value of the Batch Is Done field.', Comment = '%';
                }
                field("Batch Timestamp"; Rec."Batch Timestamp")
                {
                    ToolTip = 'Specifies the value of the Batch Timestamp field.', Comment = '%';
                }
            }
        }
    }
}

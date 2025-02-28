page 70011 "Posted Consign. Document List"
{
    ApplicationArea = All;
    Caption = 'Posted Consignment Documents';
    PageType = List;
    SourceTable = "Consignment Header";
    SourceTableView = where(Status = filter('2'));
    UsageCategory = Lists;
    CardPageId = "Posted Consignment Document";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';

                    trigger OnAction()
                    begin
                        page.Run(Page::"Consignment Document", Rec);
                    end;
                }
                action(Clear)
                {
                    caption = 'Clear Data';
                    Image = Delete;

                    trigger OnAction()
                    var
                        Txt001: Label 'Proceed to delete the consignment document?';
                    begin
                        if not Confirm(Txt001, false) then
                            exit;
                        ch.DeleteAll();
                        ce.DeleteAll();
                        cb.DeleteAll();
                    end;
                }
            }

        }
    }
    var
        ch: Record "Consignment Header";
        ce: record "Consignment Entries";
        cb: Record "Consignment Billing Entries";

}
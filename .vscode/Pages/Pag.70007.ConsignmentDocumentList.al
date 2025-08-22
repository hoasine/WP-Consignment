page 70007 "Consignment Document List"
{
    ApplicationArea = All;
    Caption = 'Consignment Documents';
    PageType = List;
    SourceTable = "Consignment Header";
    SourceTableView = where(Status = filter(<= '1'));
    AdditionalSearchTerms = 'Consignment';
    UsageCategory = Lists;
    //Editable = false;
    RefreshOnActivate = true;
    CardPageId = "Consignment Document";

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
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Email Sent field.';
                }
                field("E-Mail Sent Timestamp"; Rec."E-Mail Sent Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Sent Timestamp field.';
                }
                field("E-Mail Sent User ID"; Rec."E-Mail Sent User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Send User ID field.';
                }
            }
        }

    }
    actions
    {
        // area(Processing)
        // {
        //     action(Delete)
        //     {
        //         caption = 'Delete Multiple';
        //         Image = DeleteRow;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedIsBig = true;
        //         PromotedOnly = true;
        //         Visible = false;

        //         trigger OnAction()
        //         begin
        //             if not confirm('Are you sure you want to delete the selected document?', false) then
        //                 exit;

        //             CurrPage.SetSelectionFilter(Rec);
        //             if Rec.FindFirst() then begin
        //                 repeat
        //                     ch.Reset();
        //                     ch.SetRange("Document No.", Rec."Document No.");
        //                     ch.Delete();

        //                     ce.Reset();
        //                     ce.SetRange("Document No.", Rec."Document No.");
        //                     ce.Delete();

        //                     cb.Reset();
        //                     cb.SetRange("Document No.", Rec."Document No.");
        //                     cb.Delete();
        //                 until rec.Next() = 0;
        //                 Message('The selected documents has been deleted.');
        //             end else
        //                 Message('No line is selected');
        //             rec.Reset();
        //         end;
        //     }
        // }
        area(Navigation)
        {
            action(Card)
            {
                ApplicationArea = All;
                Caption = 'Consignment Master Type';
                Image = ServiceSetup;
                ShortCutKey = 'Shift+F7';
                RunObject = page "Consignment Master Type";
                RunPageMode = View;
            }
        }
    }
    var
        ch: Record "Consignment Header";
        ce: record "Consignment Entries";
        cb: Record "Consignment Billing Entries";

}
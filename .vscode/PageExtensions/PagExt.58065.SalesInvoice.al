pageextension 58065 SalesInvoice extends "Sales Invoice List"
{
    actions
    {
        addafter("PostAndSend")
        {
            action(BatchPrintSendSalesInvoice)
            {
                caption = 'Batch Post & Send Sales Invoice';
                ToolTip = 'Finalize and prepare to send the documents according to the customers sending profile, such as attached to an email.';
                ApplicationArea = All;
                image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Ellipsis = true;

                trigger OnAction()
                begin
                    Report.RunModal(58004, true, true, Rec);
                    CurrPage.update(False);
                end;
            }
        }
    }
}

codeunit 70003 "Consignment - Purchase Invoice"
{
    trigger OnRun()
    begin
        ProcessInvoice();
    end;

    local procedure ProcessInvoice()
    var
        ConsignmentHeader: Record "Consignment Header";
        ConsignmentEntries: Record "Consignment Entries";
        ConsignmentBillingPeriod: Record "WP B.Inc Billing Periods";
        cuConsignmentUtil: Codeunit "Consignment Util";
    begin
        //post documents-

        ConsignmentHeader.Reset();
        // ConsignmentHeader.SetCurrentKey(Status, "Start Date", "End Date");
        ConsignmentHeader.SetRange(status, ConsignmentHeader.status::Released);

        if ConsignmentHeader.FindSet() then
            repeat
                ConsignmentEntries.Reset();
                ConsignmentEntries.SetRange("Document No.", ConsignmentHeader."Document No.");
                if ConsignmentEntries.FindFirst() then;
                if ConsignmentEntries.Count <> 0 then begin
                    Clear(cuConsignmentUtil);
                    cuConsignmentUtil.CreateInvoices2(ConsignmentEntries, ConsignmentHeader);
                    ConsignmentHeader.Status := ConsignmentHeader.Status::Posted;
                    ConsignmentHeader.Modify();
                end;
            until ConsignmentHeader.Next() = 0;

        //post documents+
    end;
}
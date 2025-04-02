codeunit 70003 "Consignment - Process Invoice"
{
    trigger OnRun()
    begin
        ProcessInvoice();
        ProcessSIMNGFEE();
    end;

    local procedure ProcessSIMNGFEE()
    var
        cuConsignmentUtil: Codeunit "Consignment Util";
        bp: Record "WP Counter Area";
        ConsignmentBillingPeriod: Record "WP B.Inc Billing Periods";
    begin
        ConsignmentBillingPeriod.Reset();
        //ConsignmentBillingPeriod.SetCurrentKey("Batch is done", "Confirm Email");
        ConsignmentBillingPeriod.SetRange("Batch is Mng Fee", false);
        if ConsignmentBillingPeriod.FindFirst() then begin
            repeat
                ConsignmentBillingPeriod."Batch Is Mng Fee" := true;
                ConsignmentBillingPeriod."Batch Timestamp" := CurrentDateTime;
                ConsignmentBillingPeriod.modify(true);
            until ConsignmentBillingPeriod.Next() = 0;
            cuConsignmentUtil.CreateSIManagementFee(bp);
        end;


    end;

    local procedure ProcessInvoice()
    var
        ConsignmentHeader: Record "Consignment Header";
        ConsignmentEntries: Record "Consignment Entries";
        ConsignmentBillingPeriod: Record "WP B.Inc Billing Periods";
        cuConsignmentUtil: Codeunit "Consignment Util";
    begin
        //post documents-
        ConsignmentBillingPeriod.Reset();
        //ConsignmentBillingPeriod.SetCurrentKey("Batch is done", "Confirm Email");
        ConsignmentBillingPeriod.SetRange("Batch is done", true);
        ConsignmentBillingPeriod.SetRange("Confirm Email", true);
        if ConsignmentBillingPeriod.FindSet() then
            repeat
                ConsignmentHeader.Reset();
                // ConsignmentHeader.SetCurrentKey(Status, "Start Date", "End Date");
                ConsignmentHeader.SetRange(status, ConsignmentHeader.status::Released);
                ConsignmentHeader.SetRange("Start Date", ConsignmentBillingPeriod."Start Date");
                ConsignmentHeader.SetRange("End Date", ConsignmentBillingPeriod."End Date");
                ConsignmentHeader.SetLoadFields(Status, "Start Date", "End Date", "Document No.");
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
            until ConsignmentBillingPeriod.Next() = 0;
        //post documents+
    end;
}
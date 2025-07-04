codeunit 70002 ConsignSendEmails
{
    /*  trigger OnRun()
      begin
          ConsignmentHeader.Reset();
          ConsignmentHeader.SetCurrentKey(Status, "Start Date", "End Date");
          ConsignmentHeader.SetRange(Status, ConsignmentHeader.Status::Posted);
          ConsignmentHeader.SetLoadFields(Status, "Email Sent", "E-Mail Sent Timestamp", "E-Mail Sent User ID");
          if ConsignmentHeader.FindSet() then
              repeat
                  if not ConsignmentHeader."Email Sent" then begin
                      clear(ConsignmentUtil);
                      if ConsignmentUtil.ConsignDocSendEmail(ConsignmentHeader) = true then begin
                          ConsignmentHeader."Email Sent" := true;
                          ConsignmentHeader."E-Mail Sent Timestamp" := CurrentDateTime;
                          ConsignmentHeader."E-Mail Sent User ID" := UserId;
                          ConsignmentHeader.Modify();
                      end;
                  end;
              until ConsignmentHeader.Next() = 0;
      end;

      var
          ConsignmentHeader: record "Consignment Header";
          ConsignmentUtil: Codeunit "Consignment Util";
          */

    trigger OnRun()
    begin
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


}
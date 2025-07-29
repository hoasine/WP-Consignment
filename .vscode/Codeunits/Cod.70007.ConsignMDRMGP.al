codeunit 70007 ConsignMDRMGP
{
    trigger OnRun()
    var
        ConsignmentUtil: Codeunit "Consignment Util";
    begin
        Clear(ConsignmentUtil);
        ConsignmentUtil.GenerateBIDocs();
    end;

}
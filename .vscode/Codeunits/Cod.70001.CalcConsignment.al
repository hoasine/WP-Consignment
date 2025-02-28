/// <summary>
/// Codeunit Calc. Consignment (ID 70001).
/// </summary>
codeunit 70001 "Calc. Consignment"
{
    trigger OnRun()
    var
        ConsignmentUtil: Codeunit "Consignment Util";
    begin
        Clear(ConsignmentUtil);
        ConsignmentUtil.GenerateConsignDocs();
        ConsignmentUtil.GenerateBIDocs();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'ScheduleReport', '', false, false)]
    local procedure UpdateJobQueueTPRCategory(var Scheduled: Boolean; ReportId: Integer)
    var
        jobqueuEntry: Record "Job Queue Entry";
    begin
        if ReportId = 70008 then begin
            jobqueuEntry.Reset();
            jobqueuEntry.SetRange("Object Type to Run", jobqueuEntry."Object Type to Run"::Report);
            jobqueuEntry.SetRange("Object ID to Run", 70008);
            if jobqueuEntry.FindSet() then
                repeat
                    if jobqueuEntry."Job Queue Category Code" = '' then begin
                        jobqueuEntry."Job Queue Category Code" := 'TPR';
                        jobqueuEntry.Modify();
                        Commit();
                        Sleep(1000);
                    end;
                until jobqueuEntry.Next() = 0;
        end;
    end;
}

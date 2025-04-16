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

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintXZReport', '', false, false)]
    // internal procedure PrintXZReport(RunType: Option X,Z,Y; var Transaction: Record "LSC Transaction Header"; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var LinesPrinted: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var ReturnValue: Boolean; FiscalON: Boolean; OnlyFiscal: Boolean; gNoSuspPOSTransactionsVoided: Integer; var IsCustomZReport: Boolean)
    // var
    //     DSTR12: text[80];
    //     FieldValue: array[10] of Text[100];
    //     sender: Codeunit "LSC POS Print Utility";
    // begin
    //     Message('Handled 1 %1', IsHandled);
    //     IsHandled := true;

    //     DSTR12 := '#L##################### #R##############';
    //     FieldValue[1] := 'TEST';
    //     FieldValue[2] := format(200000);
    //     sender.PrintLine(1, 'Hello');
    //     sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
    //     sender.AddPrintLine(200, 5, FieldValue, FieldValue, DSTR1, false, true, false, false, 2);
    //     sender.PrintSeperator(3);
    //     // if (RunType = RunType::Z) or (RunType = RunType::Y) then begin
    //     //     if RunType = RunType::Z then begin
    //     //     end
    //     // end;
    //     Message('Print ok');

    //     // Handled := false;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnPrintXZReport_OnBeforePrintItemCategory', '', false, false)]
    local procedure PrintItemCategory(var ItemCategoryTemp: Record "Item Category" temporary; var IsHandled: Boolean; DSTR1: Text)
    begin
        IsHandled := true;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeCumulateSales', '', false, false)]
    local procedure wpABC(RunType: Option X,Z,Y; var Handled: Boolean)
    var
        DSTR1: text[80];
        FieldValue: array[10] of Text[100];
        sender: Codeunit "LSC POS Print Utility";
    begin
        // Message('Handled %1', Handled);
        Handled := true;

        // DSTR1 := '#L##################### #R##############';
        // FieldValue[1] := 'TEST';
        // FieldValue[2] := format(200000);

        // sender.PrintSeperator(2);
        // sender.PrintLine(2, 'TEST');
        // sender.PrintSeperator(2);


        // sender.PrintLine(1, 'Hello');
        // sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
        // sender.AddPrintLine(200, 5, FieldValue, FieldValue, DSTR1, false, true, false, false, 2);
        // sender.PrintSeperator(3);
        // if (RunType = RunType::Z) or (RunType = RunType::Y) then begin
        //     if RunType = RunType::Z then begin
        //     end
        // end;
        // Message('Print ok');

        // Handled := false;
    end;



}

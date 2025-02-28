report 70000 "Copy Consig. Setup from Vendor"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Consignment Rate"; "wp Consignment margin setup")
        {
            //dataitem("Consignment Setup"; "Consignment Setup") { }
        }
    }
    requestpage
    {

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(VendorFrom; VendorFrom) { Caption = 'Copy From Vendor No.'; TableRelation = Vendor."No."; }
                    field(CurrentVendorNo; CurrentVendorNo) { Caption = 'To Vendor No.'; Editable = false; }
                    field(OverrideFlag; OverrideFlag) { Caption = 'Override if Exists'; }
                }
            }
        }
    }

    procedure AssignParam(pCurrentVend: Code[20])
    begin
        CurrentVendorNo := pCurrentVend;
    end;

    local procedure CopyConsignmentRate()
    var
        SourceConsignRate: Record "wp Consignment margin setup";
        TargetConsignRate: Record "wp Consignment margin setup";
    begin
        CLEAR(SourceConsignRate);
        SourceConsignRate.SETRANGE("Vendor No.", VendorFrom);
        IF SourceConsignRate.FINDFIRST THEN BEGIN
            REPEAT
                CLEAR(TargetConsignRate);
                TargetConsignRate.INIT;
                TargetConsignRate.TRANSFERFIELDS(SourceConsignRate);
                TargetConsignRate."Vendor No." := CurrentVendorNo;
                TargetConsignRate.INSERT(TRUE);
            UNTIL SourceConsignRate.NEXT = 0;
        END;
    end;

    // local procedure CopyConsignmentSetup()
    // var
    //     SourceConsignStp: Record "Consignment Setup";
    //     TargetConsignStp: Record "Consignment Setup";
    // begin
    //     CLEAR(SourceConsignStp);
    //     SourceConsignStp.SETRANGE("Vendor No.", VendorFrom);
    //     IF SourceConsignStp.FINDFIRST THEN BEGIN
    //         REPEAT
    //             CLEAR(TargetConsignStp);
    //             TargetConsignStp.INIT;
    //             TargetConsignStp.TRANSFERFIELDS(SourceConsignStp);
    //             TargetConsignStp."Vendor No." := CurrentVendorNo;
    //             TargetConsignStp.INSERT(TRUE);
    //         UNTIL SourceConsignStp.NEXT = 0;
    //     END;
    // end;

    var
        VendorFrom: Code[20];
        CurrentVendorNo: Code[20];
        OverrideFlag: Boolean;
        ConsignStpCount: Integer;
        Text000: TextConst ENU = 'The copying of Consignment Rate & setup from Vendor %1 to %2 was successfully completed.';

    trigger OnPreReport()
    begin
        CopyConsignmentRate();
        //CopyConsignmentSetup();
    end;

    trigger OnPostReport()
    begin
        Message(Text000, VendorFrom, CurrentVendorNo);
    end;

}
//001   edo 20230529    Validate Date Function
table 70005 "Consignment Billing Period"
{
    Caption = 'Consignment Billing Period';
    DataClassification = ToBeClassified;
    ObsoleteState = Removed;
    ObsoleteReason = 'Table replaced by WP Billing Periods 70014';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Start Period"; Date)
        {
            Caption = 'Start Period';
            DataClassification = ToBeClassified;
            //001-
            trigger OnValidate()
            begin
                ValidateDate("Start Period", "End Period");
            end;
            //001+            
        }
        field(3; "End Period"; Date)
        {
            Caption = 'End Period';
            DataClassification = ToBeClassified;
            //001-
            trigger OnValidate()
            begin
                ValidateDate("Start Period", "End Period");
            end;
            //001+
        }
        field(4; "Billing Cut-off Date"; Date)
        {
            Caption = 'Billing Cut-off Date';
            DataClassification = ToBeClassified;
        }
        field(5; "Confirm Email"; Boolean)
        {
            Caption = 'Confirm Email';
            DataClassification = ToBeClassified;
        }
        field(100; "Batch is done"; Boolean)
        {
            Caption = 'Batch is done';
            DataClassification = ToBeClassified;
        }
        field(101; "Batch Timestamp"; DateTime)
        {
            Caption = 'Batch Timestamp';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(102; "Run By USERID"; code[100])
        {
            Caption = 'Run by USERID';
            DataClassification = ToBeClassified;
            Editable = false;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Batch is done", "Confirm Email") { }
    }
    //001-
    local procedure ValidateDate(startdate: date; enddate: date)
    var
        consignmentBillingPeriod: record "Consignment Billing Period";
        errormsg: TextConst ENU = 'Setup already exist for the combination of %1 and %2.\nPlease define a different combination setup.';
    begin
        clear(consignmentBillingPeriod);
        consignmentBillingPeriod.setrange("Start Period", startdate);
        consignmentBillingPeriod.SetRange("End Period", enddate);
        if consignmentBillingPeriod.FindSet() then begin
            error(StrSubstNo(errormsg, format(startdate), Format(enddate)));
        end;
    end;
    //001+
}

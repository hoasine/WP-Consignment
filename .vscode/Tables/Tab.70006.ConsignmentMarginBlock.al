//001   edo 20230529    Validate Start Date and End Date

table 70006 "Consignment Margin Block"
{
    Caption = 'Consignment Margin Block';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = ToBeClassified;
            //001-
            trigger onvalidate()
            begin
                ValidateDate("Start Date", "End Date");
            end;
            //001+          
        }
        field(3; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = ToBeClassified;
            //001-
            trigger onvalidate()
            begin
                ValidateDate("Start Date", "End Date");
            end;
            //001+
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Start Date", "End Date") { }
    }
    //001-
    local procedure ValidateDate(startdate: date; enddate: date)
    var
        consignmentMarginBlock: record "Consignment Margin Block";
        errormsg: TextConst ENU = 'Setup already exist for the combination of %1 and %2.\nPlease define a different combination setup.';
    begin
        clear(consignmentMarginBlock);
        consignmentMarginBlock.setrange("Start Date", startdate);
        consignmentMarginBlock.SetRange("End Date", enddate);
        if consignmentMarginBlock.FindSet() then begin
            error(StrSubstNo(errormsg, format(startdate), Format(enddate)));
        end;
    end;
    //001+
}

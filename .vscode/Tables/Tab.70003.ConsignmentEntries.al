table 70003 "Consignment Entries"
{
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "Transaction No."; Integer) { }
        field(2; "Trans. Line No."; Integer) { }
        field(3; "Store No."; Code[20]) { }
        field(4; "Receipt No."; Code[20]) { }
        field(5; "USER SID"; Guid) { }
        field(6; "Session ID"; Integer) { }
        field(7; "Sales Entry Line No."; Integer) { }
        field(10; "Barcode No."; Code[20]) { }
        field(11; "Item No."; Code[20])
        {
            trigger onValidate()
            var
                lItem: Record Item;
            begin
                if "Item No." <> '' then begin
                    lItem.Reset();
                    lItem.SetLoadFields("LSC Item Family Code");
                    if lItem.Get() then
                        if lItem."LSC Item Family Code" <> '' then
                            "Item Family Code" := lItem."LSC Item Family Code";
                end;
            end;
        }
        field(12; "Date"; Date) { }
        field(13; "Vendor No."; Code[20])
        {
            TableRelation = "Vendor"."No.";
        }
        field(14; "Division"; Code[20])
        {
            TableRelation = "LSC Division".Code;
        }
        field(15; "Item Category"; Code[20])
        {
            TableRelation = "Item Category".Code;

        }
        field(16; "Product Group"; Code[20])
        {
            TableRelation = "LSC Retail Product Group".Code;

        }
        field(17; "Special Group"; Code[20])
        {
            TableRelation = "LSC Item Special Groups".Code;
        }
        field(18; "Product Group Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Retail Product Group".Description where(Code = field("Product Group")));
            Editable = false;
        }
        field(20; Quantity; Decimal) { DecimalPlaces = 0 : 3; }
        field(21; Price; Decimal) { }
        field(22; UOM; Code[10]) { }
        field(23; "Net Amount"; Decimal) { }
        field(24; "VAT Amount"; Decimal) { }
        field(25; "Discount Amount"; Decimal) { }
        field(26; "Cost Amount"; Decimal) { }
        field(27; "Net Amount (LCY)"; Decimal) { }
        field(28; "VAT Amount (LCY)"; Decimal) { }
        field(29; "Discount Amount (LCY)"; Decimal) { }
        field(30; "Cost Amount (LCY)"; Decimal) { }
        field(31; "Tax Rate"; Decimal) { }
        field(32; "Discount %"; Decimal) { }
        field(50; "Member Card No."; Code[20]) { }
        field(60; "Promotion No."; Code[20]) { }
        field(61; "Periodic Disc. Type"; Option)
        {
            OptionMembers = " ",Multibuy,"Mix&Match","Disc. Offer","Deal","Line Disc.";
            OptionCaption = ' ,Multibuy,Mix&Match,Disc. Offer,Deal,Line Disc.';
        }
        field(62; "Periodic Offer No."; Code[20]) { }
        field(63; "Periodic Discount Amount"; Decimal) { }
        field(64; "Periodic Discount Amount (LCY)"; Decimal) { }
        field(70; "VAT Code"; Code[20]) { }
        field(50107; "VAT Prod. Posting Group"; Code[20]) { Caption = 'VAT Prod. Posting Group'; }
        field(71; "Return No Sales"; Boolean) { }
        field(72; "Item Description"; Text[100]) { }
        field(73; "Currency Code"; Code[10]) { }
        field(74; "Exch. Rate"; Decimal) { }
        field(80; "Consignment Type"; Code[20]) { }
        field(81; "Consignment %"; Decimal)
        {
            DecimalPlaces = 0 : 2;
            Caption = 'Profit Margin %';
        }
        field(82; "Consignment Amount"; Decimal)
        {
            Caption = 'Profit Excl Tax';
            trigger OnValidate()
            begin
                "Consignment Cost" := "Total Excl Tax" - "Consignment Amount";
            end;
        }
        field(83; "Consignment Amount (LCY)"; Decimal) { }
        field(84; "Gross Price"; decimal) { }
        field(85; "Disc. Amount From Std. Price"; decimal)
        {
            Caption = 'Disc per unit';
        }
        field(86; "VAT per unit"; decimal) { }
        field(87; "Net Price Incl Tax"; decimal) { }
        field(88; "Total Incl Tax"; decimal) { }
        field(89; "Tax"; decimal) { }
        field(90; "Total Tax Collected"; decimal) { }
        field(91; "Net Price Excl Tax"; decimal) { }
        field(92; "Total Excl Tax"; decimal)
        {
            trigger OnValidate()
            begin
                "Consignment Cost" := "Total Excl Tax" - "Consignment Amount";
            end;
        }
        field(93; "Special Group Description"; text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Item Special Groups".Description where("Code" = field("Special Group")));
            Editable = false;
        }
        field(94; "Applied to Billing Line No."; Integer) { Editable = false; }
        field(95; "Consignment Cost"; Decimal) { }
        field(100; "Created By"; Code[50]) { }
        field(101; "Created Date"; DateTime) { }
        field(102; "Item Family Code"; code[10]) { }
        field(103; "Vendor Posting Group"; code[20]) { TableRelation = "Vendor Posting Group"; }
        field(110; Cost; Decimal) { Caption = 'Cost Excl Tax'; }
        field(1000; "Document No."; code[50]) { }
        field(1001; "Line No."; Integer) { }
        field(1002; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
        }
        field(1003; "Cost Incl Tax"; Decimal)
        {
            Caption = 'Cost Incl Tax';
        }
        field(50000; "Item Category Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category".Description where(Code = field("Item Category")));
            Editable = false;
        }
        field(50001; "Special Group 2"; Code[20]) { Caption = 'Special Group 2 (Prefix C)'; }
        field(50002; "Special Group 2 Description"; text[30])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Item Special Groups".Description where("Code" = field("Special Group 2")));
            Editable = false;
        }
        field(50003; "Total Discount"; code[20]) { TableRelation = "LSC Periodic Discount"."No." where(Type = filter("Total Discount")); }
        field(50004; "Total Discount Desc"; text[100])
        {
            FieldClass = FlowField;
            calcformula = lookup("LSC Periodic Discount"."Description" where("No." = field("Total Discount")));
        }
        field(50100; "MDR Rate"; Decimal)
        {
            DecimalPlaces = 0 : 3;
        }
        field(50101; "MDR Weight"; Decimal)
        {
            DecimalPlaces = 0 : 3;
        }
        field(50102; "MDR Amount"; Decimal) { }
        field(50103; "MDR Rate Pctg"; Decimal) { DecimalPlaces = 0 : 3; }
        field(50104; "Contract ID"; Code[20])
        {
            Caption = 'Contract ID';
            TableRelation = "WP Consignment Contracts".ID;
        }
        field(50105; "Billing Period ID"; Code[20])
        {
            Caption = 'Billing Period ID';
            TableRelation = "WP B.Inc Billing Periods".ID;
        }
        field(50106; "Expected Gross Profit"; Decimal) { Caption = 'Expected Gross Profit'; }
    }
    keys
    {
        key(PK; "Document No.", "Line No.", "USER SID")
        {
            Clustered = true;
        }
        key(Key2; "Created By", "Vendor No.", Date) { }
    }
}
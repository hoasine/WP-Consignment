tableextension 58040 WPItemJournalLine extends "Item Journal Line"
{
    fields
    {
        field(99000767; "LSC Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 2;
            DataClassification = CustomerContent;
        }

        field(99000768; "LSC Brand Name"; text[50])
        {
            Caption = 'Brand Name';
            DataClassification = CustomerContent;
        }

        field(99000769; "LSC Special Group"; text[50])
        {
            Caption = 'Special Group Code';
            DataClassification = CustomerContent;
            ValidateTableRelation = false;
            TableRelation = "LSC Item/Special Group Link"."Special Group Code";
        }
    }

    trigger OnBeforeInsert()
    begin
        LockTable();
        GetBarcodeAndUnitPrice();
        GetSpecialGroup();
    end;

    local procedure GetSpecialGroup()
    var
        SP: Record "LSC Item/Special Group Link";
    begin
        begin
            if Rec."Item No." = '' then
                exit;

            clear(SP);
            SP.SetRange("Item No.", Rec."Item No.");
            SP.FindFirst();

            if SP.FindFirst() then begin
                repeat
                    "LSC Special Group" := SP."Special Group Code";
                until SP.next = 0;
            end;
        end;
    end;

    local procedure GetBarcodeAndUnitPrice()
    var
        LRecIJL: Record "Item Journal Line";
        LRecBarc: record "LSC Barcodes";
        LRecItem: Record Item;
        LRecRS: Record "LSC Retail Setup";
        TempBlob: Codeunit "Temp Blob";
        PriceUtil: Codeunit "LSC Retail Price Utils";
        OutStr: OutStream;
        InStr: InStream;
        TxtStr: Text;
        FileName: Text;
        CRLF: TEXT[2];
        UTF: TextEncoding;
        UnitPrice: decimal;
        CalcQtyOnHand: Report "Calculate Inventory";
    begin
        begin
            if Rec."Item No." = '' then
                exit;

            clear(LRecRS);
            lrecrs.get;

            clear(LRecItem);
            lrecitem.get(Rec."Item No.");

            if lrecitem.get(LRecIJL."Item No.") then;
            clear(LRecBarc);
            LRecBarc.setrangE("Item No.", Rec."Item No.");
            if Rec."Unit of Measure Code" <> '' then
                LRecBarc.setrange("Unit of Measure Code", Rec."Unit of Measure Code");
            if LRecBarc."Variant Code" <> '' then
                LRecBarc.SetRange("Variant Code", Rec."Variant Code");
            if LRecBarc.FindFirst() then begin
                repeat

                    "LSC Unit Price" := PriceUtil.GetValidRetailPrice2(Rec."Location Code", Rec."Item No.", Rec."Posting Date", 0T, Rec."Unit of Measure Code",
                                Rec."Variant Code", LRecItem."VAT Bus. Posting Gr. (Price)", '', lrecrs."Default Price Group", '', '');

                    "LSC Barcode" := LRecBarc."Barcode No.";

                until LRecBarc.next = 0;
            end;
        end;
    end;

}

pageextension 58068 "WP Physical Inventory Journal" extends "Phys. Inventory Journal"
{
    layout
    {
        addlast(Control1)
        {
            field("Barcode"; Rec."LSC Barcode")
            {
                ApplicationArea = All;
            }

            field("Unit Price"; Rec."LSC Unit Price")
            {
                ApplicationArea = All;
            }

            field("Special Group"; Rec."LSC Special Group")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addbefore(Print)
        {
            action(ExportToVietA)
            {
                Caption = 'Export to VietA';
                ToolTip = 'Export the content to VietA';
                ApplicationArea = All;
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Ellipsis = true;

                trigger OnAction()
                begin
                    ExportToVietA();
                end;
            }
        }
        addbefore("P&ost")
        {
            action(ImportFromVietA)
            {
                Caption = 'Import from VietA';
                ToolTip = 'Import the content from VietA';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                Ellipsis = true;
                trigger OnAction()
                begin
                    //ImportFromExcel();
                    ImportFrVietA();
                end;
            }
        }
    }

    local procedure ExportToVietA()
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
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        clear(LRecIJL);
        LRecIJL.setrange("Journal Batch Name", Rec."Journal Batch Name");
        LRecIJL.setrange("Journal Template Name", Rec."Journal Template Name");
        if LRecIJL.FindFirst() then begin
            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            FileName := rec."Journal Batch Name" + rec."Journal Batch Name" + '.csv';
            repeat
                clear(LRecRS);
                lrecrs.get;
                clear(LRecItem);
                if lrecitem.get(LRecIJL."Item No.") then;
                clear(LRecBarc);
                LRecBarc.setrangE("Item No.", LRecIJL."Item No.");
                if LRecIJL."Unit of Measure Code" <> '' then
                    LRecBarc.setrange("Unit of Measure Code", LRecIJL."Unit of Measure Code");
                if LRecBarc."Variant Code" <> '' then
                    LRecBarc.SetRange("Variant Code", LRecIJL."Variant Code");
                if LRecBarc.FindFirst() then begin
                    repeat
                        // StoreCode: Code[10]
                        // ItemNo: Code[20]
                        // DateValid: Date 
                        // timeVal: Time
                        // SalesUnitOfMeasure: Code[10]
                        // VariantCode: Code[10]
                        // VatBusPostingGroup: Code[20]
                        // CurrencyCode: Code[10]
                        // PriceGroupCode: Code[10]
                        // SalesType: Code[20]
                        // CustDiscGroup: Code[20]
                        UnitPrice := PriceUtil.GetValidRetailPrice2(LRecIJL."Location Code", LRecIJL."Item No.", LRecIJL."Posting Date", 0T, LRecIJL."Unit of Measure Code",
                        LRecIJL."Variant Code", LRecItem."VAT Bus. Posting Gr. (Price)", '', lrecrs."Default Price Group", '', '');

                        TxtStr := LRecBarc."Barcode No." + ',' + LRecIJL.Description + ',' + FORMAT(UnitPrice).Replace(',', '') + CRLF;

                        OutStr.WriteText(TxtStr);
                    until LRecBarc.next = 0;
                end;
            until LRecIJL.Next() = 0;
            TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
            DownloadFromStream(InStr, '', '', '', FileName);
        end;
    end;

    local procedure ImportFrVietA()
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        TxtStr: Text;
        Line: Text;
        LRecIJL: Record "Item Journal Line";
        LRecBarc: record "LSC Barcodes";
        FileName: Text;
        FileUploaded: Boolean;
        lLTxtSKU: text;
        lTxtDesc: text;
        lDecQty: decimal;
    begin
        FileUploaded := UploadIntoStream('Import Text File', '', '', FileName, InStr);
        if not FileUploaded then exit;
        // Read and process each line of the file
        while not InStr.EOS do begin
            InStr.ReadText(Line);
            // Process the line (e.g., split by comma and insert into a record)
            // Example: Split the line by comma and insert into Item Journal Line
            TxtStr := Line;
            lLTxtSKU := CopyStr(TxtStr, 1, StrPos(TxtStr, ',') - 1);
            txtstr := txtstr.Remove(1, StrPos(TxtStr, ','));
            lTxtDesc := CopyStr(TxtStr, 1, StrPos(TxtStr, ',') - 1);
            txtstr := txtstr.remove(1, StrPos(TxtStr, ','));
            lDecQty := EvaluateDecimal(TxtStr);

            clear(LRecBarc);
            LRecBarc.setrange("Barcode No.", lLTxtSKU);
            if LRecBarc.FindFirst() then begin
                clear(LRecIJL);
                LRecIJL.setrange("Item No.", LRecBarc."Item No.");
                lrecijl.setrange("Unit of Measure Code", LRecBarc."Unit of Measure Code");
                if LRecBarc."Variant Code" <> '' then
                    LRecIJL.setrange("Variant Code", LRecBarc."Variant Code");
                lrecijl.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                lrecijl.SetRange("Journal Template Name", Rec."Journal Template Name");
                if lrecijl.FindFirst() then begin
                    lrecijl.validate("Qty. (Phys. Inventory)", lDecQty);
                    lrecijl.Modify();
                end;
            end;
        end;
    end;

    // trigger OnAfterGetRecord()
    // var
    //     LRecIJL: Record "Item Journal Line";
    //     LRecBarc: record "LSC Barcodes";
    //     LRecItem: Record Item;
    //     LRecRS: Record "LSC Retail Setup";
    //     TempBlob: Codeunit "Temp Blob";
    //     PriceUtil: Codeunit "LSC Retail Price Utils";
    //     OutStr: OutStream;
    //     InStr: InStream;
    //     TxtStr: Text;
    //     FileName: Text;
    //     CRLF: TEXT[2];
    //     UTF: TextEncoding;
    //     UnitPrice: decimal;
    // begin
    //     begin
    //         if Rec."Item No." = '' then
    //             exit;

    //         clear(LRecRS);
    //         lrecrs.get;

    //         clear(LRecItem);
    //         lrecitem.get(Rec."Item No.");

    //         if lrecitem.get(LRecIJL."Item No.") then;
    //         clear(LRecBarc);
    //         LRecBarc.setrangE("Item No.", Rec."Item No.");
    //         if Rec."Unit of Measure Code" <> '' then
    //             LRecBarc.setrange("Unit of Measure Code", Rec."Unit of Measure Code");
    //         if LRecBarc."Variant Code" <> '' then
    //             LRecBarc.SetRange("Variant Code", Rec."Variant Code");
    //         if LRecBarc.FindFirst() then begin
    //             repeat

    //                 Rec."LSC Unit Price" := PriceUtil.GetValidRetailPrice2(Rec."Location Code", Rec."Item No.", Rec."Posting Date", 0T, Rec."Unit of Measure Code",
    //                             Rec."Variant Code", LRecItem."VAT Bus. Posting Gr. (Price)", '', lrecrs."Default Price Group", '', '');

    //                 Rec."LSC Barcode" := LRecBarc."Barcode No.";

    //             until LRecBarc.next = 0;
    //         end;
    //     end;
    // end;




    local procedure EvaluateDecimal(Value: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        if Evaluate(DecimalValue, Value) then
            exit(DecimalValue)
        else
            exit(0);
    end;
}

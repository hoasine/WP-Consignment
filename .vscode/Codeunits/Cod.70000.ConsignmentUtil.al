codeunit 70000 "Consignment Util"
{
    procedure GetInfo(pVendNo: Code[20]; pStartDate: Date; pEndDate: Date; pStoreNo: Code[10])
    begin
        VendNo := pVendNo;
        StoreNo := pStoreNo;
        StartDate := pStartDate;
        EndDate := pEndDate;
    end;

    procedure DeleteSalesDateBySession()
    var
        POSSalesEntry: Record "Consignment Entries";
    begin
        POSSalesEntry.Reset();
        POSSalesEntry.SetFilter("Document No.", ''''''); //20240124-+
        POSSalesEntry.SetRange("USER SID", UserSecurityId());
        if not POSSalesEntry.IsEmpty then
            POSSalesEntry.DeleteAll();
    end;

    procedure CopySalesData(pStartDate: Date; pEndDate: Date; pStoreNo: Code[10]; pVendor: code[20])
    var
        TransHeader: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        POSSales: Record "Consignment Entries";
        Item: Record item;
        ItemSpecialGrp: Record "LSC Item/Special Group Link";
        Barc: Record "LSC barcodes";
        CurrExcRate: Record "Currency Exchange Rate";
        POSVAT: Record "LSC POS VAT Code";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        discPerc: Decimal;
        ckDiscount: Decimal;
        CostAmountActual: Decimal;
        CostPerUnit: Decimal;
        ConsignGroup: text[250];
        StoreVendor: code[20];
        i: Integer;
        Dialog: Dialog;
        nextLineNo: Integer;
    begin
        POSSales.Reset();
        POSSales.SetFilter("Document No.", ''''''); //20240124-+
        POSSales.SetRange("USER SID", UserSecurityId());
        if not POSSales.IsEmpty then
            POSSales.DeleteAll();

        i := 0;
        nextLineNo := 1;

        TransHeader.Reset();
        TransHeader.SetCurrentKey("Store No.", Date);
        if (pStoreNo <> '') then
            TransHeader.SetRange("Store No.", pStoreNo);
        TransHeader.SetRange(Date, pStartDate, pEndDate);
        TransHeader.SetFilter("Entry Status", '0|2');
        TransHeader.SetLoadFields(Date, "Entry Status", "Posted Statement No.", "Member Card No.", "Trans. Currency");
        if TransHeader.FindSet() then begin
            if GuiAllowed then begin
                Dialog.Open('Processing ' + 'Transaction' + ' #1########## of #2##########\');
                Dialog.update(2, format(TransHeader.Count));
            end;
            TransHeader.SetLoadFields("Posted Statement No.");
            repeat
                i += 1;
                if GuiAllowed then Dialog.update(1, format(i));

                SalesEntry.Reset();
                SalesEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", Date, "Gen. Prod. Posting Group");
                SalesEntry.SetRange("Store No.", TransHeader."Store No.");
                SalesEntry.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                SalesEntry.SetRange("Transaction No.", TransHeader."Transaction No.");
                SalesEntry.SetRange(Date, pStartDate, pEndDate);
                ConsignGroup := GetConsignPostGroup();
                if ConsignGroup <> '' then SalesEntry.SetFilter("Gen. Prod. Posting Group", ConsignGroup);
                if SalesEntry.FindSet() then
                    repeat
                        POSSales.Reset();
                        POSSales.Init();
                        POSSales."Transaction No." := SalesEntry."Transaction No.";
                        POSSales."Line No." := nextLineNo;
                        POSSales."Receipt No." := SalesEntry."Receipt No.";
                        POSSales.Validate("Item No.", SalesEntry."Item No.");
                        POSSales.Date := SalesEntry.Date;
                        POSSales."Store No." := SalesEntry."Store No.";

                        Item.Reset();
                        Item.SetLoadFields("LSC Item Family Code", "LSC Division Code", Description, "Vendor No.");
                        if Item.Get(SalesEntry."Item No.") then;

                        // clear(StoreVendor);
                        // StoreVendor := GetVendorCode(SalesEntry);
                        // POSSales."Vendor No." := StoreVendor;
                        POSSales."Vendor No." := Item."Vendor No.";
                        POSSales."Item Family Code" := Item."LSC Item Family Code";
                        POSSales.Division := Item."LSC Division Code";
                        POSSales."Item Category" := SalesEntry."Item Category Code";
                        POSSales."Product Group" := SalesEntry."Retail Product Code";
                        POSSales."Item Description" := Item.Description;

                        ItemSpecialGrp.Reset();
                        ItemSpecialGrp.SetRange("Item No.", SalesEntry."Item No.");
                        ItemSpecialGrp.SetLoadFields("Item Name");
                        if ItemSpecialGrp.FindFirst() then begin
                            repeat
                                if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'B' then
                                    POSSales."Special Group" := ItemSpecialGrp."Special Group Code";

                                if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'C' then
                                    POSSales."Special Group 2" := ItemSpecialGrp."Special Group Code";
                            until ItemSpecialGrp.Next() = 0;
                        end;
                        if SalesEntry."Barcode No." <> '' then
                            POSSales."Barcode No." := SalesEntry."Barcode No."
                        else begin
                            Barc.Reset();
                            Barc.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
                            Barc.SetRange("Item No.", SalesEntry."Item No.");
                            Barc.SetRange("Unit of Measure Code", SalesEntry."Unit of Measure");
                            Barc.SetLoadFields("Item No.", "Unit of Measure Code");
                            if Barc.FindFirst() then
                                POSSales."Barcode No." := Barc."Barcode No.";
                        end;

                        POSVAT.Reset();
                        if POSVAT.Get(SalesEntry."VAT Code") then;

                        POSSales.Quantity := -SalesEntry.Quantity;
                        POSSales.Price := SalesEntry.Price;
                        POSSales.UOM := SalesEntry."Unit of Measure";
                        POSSales."Net Amount" := -SalesEntry."Net Amount";
                        POSSales."VAT Amount" := -SalesEntry."VAT Amount";
                        POSSales."Discount Amount" := ((100 - posvat."VAT %") / 100) * SalesEntry."Discount Amount";
                        POSSales."Promotion No." := SalesEntry."Promotion No.";
                        POSSales."Periodic Disc. Type" := SalesEntry."Periodic Disc. Type";
                        POSSales."Periodic Offer No." := SalesEntry."Periodic Disc. Group";

                        TransDiscEntry.Reset();
                        TransDiscEntry.SetRange("Store No.", SalesEntry."Store No.");
                        TransDiscEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
                        TransDiscEntry.SetRange("Line No.", SalesEntry."Line No.");
                        TransDiscEntry.SetRange("Receipt No.", SalesEntry."Receipt No.");
                        if TransDiscEntry.FindFirst() then begin
                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Line Discount") then begin
                                POSSales."Periodic Disc. Type" := POSSales."Periodic Disc. Type"::"Line Disc.";
                                POSSales."Periodic Offer No." := TransDiscEntry."Offer No.";
                            end;
                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Total Discount") then
                                POSSales."Total Discount" := TransDiscEntry."Offer No.";
                        end;

                        POSSales."Periodic Discount Amount" := SalesEntry."Periodic Discount";
                        POSSales."VAT Code" := SalesEntry."VAT Code";
                        POSSales."Return No Sales" := SalesEntry."Return No Sale";
                        POSSales."Cost Amount" := -SalesEntry."Cost Amount";
                        POSSales."USER SID" := USERSECURITYID;
                        POSSales."Session ID" := SESSIONID;
                        POSSales."Created By" := USERID;
                        POSSales."Created Date" := CURRENTDATETIME;

                        //CalcConsignment(POSSales."Vendor No.", POSSales.Date, POSSales, POSSales."Consignment Type");
                        POSSales."Consignment %" := CalcConsignPerc_all(POSSales);
                        if POSSales."Consignment %" <> 0 then
                            POSSales."Consignment Amount" := ROUND(POSSales."Net Amount" * (POSSales."Consignment %" / 100))
                        else
                            POSSales."Consignment Amount" := 0;

                        POSSales."Member Card No." := TransHeader."Member Card No.";
                        POSSales."Currency Code" := TransHeader."Trans. Currency";

                        if POSSales."Currency Code" <> '' then begin
                            CurrExcRate.Reset();
                            CurrExcRate.SetRange("Currency Code", POSSales."Currency Code");
                            CurrExcRate.SetFilter("Starting Date", '<=%1', POSSales.Date);
                            CurrExcRate.SetLoadFields("Relational Exch. Rate Amount");
                            if CurrExcRate.FindFirst() then
                                POSSales."Exch. Rate" := CurrExcRate."Relational Exch. Rate Amount";
                        end;
                        if POSSales."Exch. Rate" <> 0 then begin
                            POSSales."Net Amount (LCY)" := Round(POSSales."Net Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."VAT Amount (LCY)" := Round(POSSales."VAT Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Discount Amount (LCY)" := Round(POSSales."Discount Amount (LCY)" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Periodic Discount Amount (LCY)" := Round(POSSales."Periodic Discount Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                            POSSales."Consignment Amount (LCY)" := Round(POSSales."Consignment Amount" * POSSales."Exch. Rate", 1, '=');
                        end else begin
                            POSSales."Net Amount (LCY)" := POSSales."Net Amount";
                            POSSales."VAT Amount (LCY)" := POSSales."VAT Amount";
                            POSSales."Discount Amount (LCY)" := POSSales."Discount Amount";
                            POSSales."Periodic Discount Amount (LCY)" := POSSales."Periodic Discount Amount";
                            POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                            POSSales."Consignment Amount (LCY)" := POSSales."Consignment Amount";
                        end;

                        POSSales."Gross Price" := SalesEntry."Net Price";

                        if POSSales.Quantity <> 0 then begin
                            POSSales."Disc. Amount From Std. Price" := round(POSSales."Discount Amount" / POSSales.Quantity);
                            POSSales."Net Price Incl Tax" := -(SalesEntry."Net Amount" + SalesEntry."VAT Amount") / POSSales.Quantity;
                        end;

                        if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                            POSSales."VAT per unit" := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);

                        POSSales."Total Incl Tax" := -(SalesEntry."Net Amount" + SalesEntry."VAT Amount");
                        if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                            POSSales.Tax := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);
                        POSSales."Total Tax Collected" := SalesEntry."VAT Amount";

                        POSSales."Total Excl Tax" := -SalesEntry."Net Amount";
                        if POSSales.Quantity <> 0 then
                            POSSales."Net Price Excl Tax" := POSSales."Total Excl Tax" / POSSales.Quantity;

                        POSSales.Cost := POSSales."Net Amount" - POSSales."Consignment Amount";
                        POSSales."Cost Incl Tax" := POSSales.Cost + ((POSSales.Cost * POSVAT."VAT %") / 100); //UAT-025:Cost Inc Tax :=No9+No.11
                        getMDR(SalesEntry, possales."MDR Rate", possales."MDR Weight", possales."MDR Amount");
                        POSSales."MDR Rate Pctg" := possales."MDR Rate" * 100;
                        if pVendor <> '' then begin
                            if POSSales."Vendor No." = pVendor then begin
                                POSSales.Insert()
                            end;
                        end else begin
                            POSSales.Insert();
                        end;

                        // if StoreVendor <> '' then begin
                        //     if (pVendor <> '') then
                        //         if StoreVendor = pVendor then
                        //             POSSales.Insert()
                        // end else begin
                        //     POSSales.Insert();
                        // end;

                        nextLineNo += 1;
                    until SalesEntry.Next() = 0;
            until TransHeader.Next() = 0;
            if GuiAllowed then
                Dialog.Close();
        end;
    end;

    procedure CopySalesData2(pStartDate: Date; pEndDate: Date; pStoreNo: Code[10]; pVendor: code[20]; pContract: Code[20])
    var
        TransHeader: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        POSSales: Record "Consignment Entries";
        Item: Record item;
        ItemSpecialGrp: Record "LSC Item/Special Group Link";
        Barc: Record "LSC barcodes";
        CurrExcRate: Record "Currency Exchange Rate";
        POSVAT: Record "LSC POS VAT Code";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        discPerc: Decimal;
        ckDiscount: Decimal;
        CostAmountActual: Decimal;
        CostPerUnit: Decimal;
        ConsignGroup: text[250];
        StoreVendor: code[20];
        i: Integer;
        Dialog: Dialog;
        nextLineNo: Integer;
        LRecVendor: Record Vendor;
        LRecCNS: record "WP Consignment Margin Setup";
    begin
        POSSales.Reset();
        POSSales.SetFilter("Document No.", ''''''); //20240124-+
        POSSales.SetRange("USER SID", UserSecurityId());
        if not POSSales.IsEmpty then
            POSSales.DeleteAll();

        i := 0;
        nextLineNo := 1;
        clear(LRecCNS);
        LRecCNS.setrange("Vendor No.", pVendor);
        if pStoreNo <> '' then
            LRecCNS.setrange("Store No.", pStoreNo);
        LRecCNS.SetFilter("Start Date", '<=%1', pStartDate);
        LRecCNS.SetFilter("End Date", '>= %1', pEndDate);
        if LRecCNS.FindFirst() then begin
            repeat
                SalesEntry.Reset();
                SalesEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", Date, "Gen. Prod. Posting Group");
                SalesEntry.SetRange("Store No.", LRecCNS."Store No.");
                SalesEntry.SetRange("Item No.", LRecCNS."Item No.");
                SalesEntry.SetRange(Date, pStartDate, pEndDate);
                SalesEntry.SetRange("Discount %", LRecCNS."Disc. From", LRecCNS."Disc. To");
                ConsignGroup := GetConsignPostGroup();
                if ConsignGroup <> '' then SalesEntry.SetFilter("Gen. Prod. Posting Group", ConsignGroup);
                if SalesEntry.FindSet() then
                    repeat
                        POSSales.Reset();
                        POSSales.Init();
                        POSSales."Transaction No." := SalesEntry."Transaction No.";
                        POSSales."Line No." := nextLineNo;
                        POSSales."Receipt No." := SalesEntry."Receipt No.";
                        POSSales.Validate("Item No.", SalesEntry."Item No.");
                        POSSales.Date := SalesEntry.Date;
                        POSSales."Store No." := SalesEntry."Store No.";

                        Item.Reset();
                        Item.SetLoadFields("LSC Item Family Code", "LSC Division Code", Description, "Vendor No.");
                        if Item.Get(SalesEntry."Item No.") then;

                        // clear(StoreVendor);
                        // StoreVendor := GetVendorCode(SalesEntry);
                        // POSSales."Vendor No." := StoreVendor;
                        POSSales."Vendor No." := pVendor;
                        POSSales."Item Family Code" := Item."LSC Item Family Code";
                        POSSales.Division := Item."LSC Division Code";
                        POSSales."Item Category" := SalesEntry."Item Category Code";
                        POSSales."Product Group" := SalesEntry."Retail Product Code";
                        POSSales."Item Description" := Item.Description;

                        ItemSpecialGrp.Reset();
                        ItemSpecialGrp.SetRange("Item No.", SalesEntry."Item No.");
                        ItemSpecialGrp.SetLoadFields("Item Name");
                        if ItemSpecialGrp.FindFirst() then begin
                            repeat
                                if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'B' then
                                    POSSales."Special Group" := ItemSpecialGrp."Special Group Code";

                                if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'C' then
                                    POSSales."Special Group 2" := ItemSpecialGrp."Special Group Code";
                            until ItemSpecialGrp.Next() = 0;
                        end;
                        if SalesEntry."Barcode No." <> '' then
                            POSSales."Barcode No." := SalesEntry."Barcode No."
                        else begin
                            Barc.Reset();
                            Barc.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
                            Barc.SetRange("Item No.", SalesEntry."Item No.");
                            Barc.SetRange("Unit of Measure Code", SalesEntry."Unit of Measure");
                            Barc.SetLoadFields("Item No.", "Unit of Measure Code");
                            if Barc.FindFirst() then
                                POSSales."Barcode No." := Barc."Barcode No.";
                        end;

                        POSVAT.Reset();
                        if POSVAT.Get(SalesEntry."VAT Code") then;

                        POSSales.Quantity := -SalesEntry.Quantity;
                        POSSales.Price := SalesEntry.Price;
                        POSSales.UOM := SalesEntry."Unit of Measure";
                        POSSales."Net Amount" := -SalesEntry."Net Amount";
                        POSSales."VAT Amount" := -SalesEntry."VAT Amount";
                        POSSales."Discount Amount" := ((100 - posvat."VAT %") / 100) * SalesEntry."Discount Amount";
                        POSSales."Promotion No." := SalesEntry."Promotion No.";
                        POSSales."Periodic Disc. Type" := SalesEntry."Periodic Disc. Type";
                        POSSales."Periodic Offer No." := SalesEntry."Periodic Disc. Group";

                        TransDiscEntry.Reset();
                        TransDiscEntry.SetRange("Store No.", SalesEntry."Store No.");
                        TransDiscEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
                        TransDiscEntry.SetRange("Line No.", SalesEntry."Line No.");
                        TransDiscEntry.SetRange("Receipt No.", SalesEntry."Receipt No.");
                        if TransDiscEntry.FindFirst() then begin
                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Line Discount") then begin
                                POSSales."Periodic Disc. Type" := POSSales."Periodic Disc. Type"::"Line Disc.";
                                POSSales."Periodic Offer No." := TransDiscEntry."Offer No.";
                            end;
                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Total Discount") then
                                POSSales."Total Discount" := TransDiscEntry."Offer No.";
                        end;

                        POSSales."Periodic Discount Amount" := SalesEntry."Periodic Discount";
                        POSSales."VAT Code" := SalesEntry."VAT Code";
                        POSSales."Return No Sales" := SalesEntry."Return No Sale";
                        POSSales."Cost Amount" := -SalesEntry."Cost Amount";
                        POSSales."USER SID" := USERSECURITYID;
                        POSSales."Session ID" := SESSIONID;
                        POSSales."Created By" := USERID;
                        POSSales."Created Date" := CURRENTDATETIME;
                        POSSales."Discount %" := SalesEntry."Discount %";

                        //CalcConsignment(POSSales."Vendor No.", POSSales.Date, POSSales, POSSales."Consignment Type");
                        POSSales."Consignment %" := CalcConsignPerc(POSSales, pContract);
                        //POSSales."Consignment %" := LRecCNS."Profit Margin";
                        if POSSales."Consignment %" <> 0 then
                            POSSales."Consignment Amount" := ROUND(POSSales."Net Amount" * (POSSales."Consignment %" / 100))
                        else
                            POSSales."Consignment Amount" := 0;

                        clear(TransHeader);
                        TransHeader.setrange("Receipt No.", POSSales."Receipt No.");
                        if TransHeader.FindFirst() then;

                        POSSales."Member Card No." := TransHeader."Member Card No.";
                        POSSales."Currency Code" := TransHeader."Trans. Currency";

                        if POSSales."Currency Code" <> '' then begin
                            CurrExcRate.Reset();
                            CurrExcRate.SetRange("Currency Code", POSSales."Currency Code");
                            CurrExcRate.SetFilter("Starting Date", '<=%1', POSSales.Date);
                            CurrExcRate.SetLoadFields("Relational Exch. Rate Amount");
                            if CurrExcRate.FindFirst() then
                                POSSales."Exch. Rate" := CurrExcRate."Relational Exch. Rate Amount";
                        end;
                        if POSSales."Exch. Rate" <> 0 then begin
                            POSSales."Net Amount (LCY)" := Round(POSSales."Net Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."VAT Amount (LCY)" := Round(POSSales."VAT Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Discount Amount (LCY)" := Round(POSSales."Discount Amount (LCY)" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Periodic Discount Amount (LCY)" := Round(POSSales."Periodic Discount Amount" * POSSales."Exch. Rate", 1, '=');
                            POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                            POSSales."Consignment Amount (LCY)" := Round(POSSales."Consignment Amount" * POSSales."Exch. Rate", 1, '=');
                        end else begin
                            POSSales."Net Amount (LCY)" := POSSales."Net Amount";
                            POSSales."VAT Amount (LCY)" := POSSales."VAT Amount";
                            POSSales."Discount Amount (LCY)" := POSSales."Discount Amount";
                            POSSales."Periodic Discount Amount (LCY)" := POSSales."Periodic Discount Amount";
                            POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                            POSSales."Consignment Amount (LCY)" := POSSales."Consignment Amount";
                        end;

                        POSSales."Gross Price" := SalesEntry."Net Price";

                        if POSSales.Quantity <> 0 then begin
                            POSSales."Disc. Amount From Std. Price" := round(POSSales."Discount Amount" / POSSales.Quantity);
                            POSSales."Net Price Incl Tax" := -(SalesEntry."Net Amount" + SalesEntry."VAT Amount") / POSSales.Quantity;
                        end;

                        if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                            POSSales."VAT per unit" := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);

                        POSSales."Total Incl Tax" := -(SalesEntry."Net Amount" + SalesEntry."VAT Amount");
                        if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                            POSSales.Tax := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);
                        POSSales."Total Tax Collected" := SalesEntry."VAT Amount";

                        POSSales."Total Excl Tax" := -SalesEntry."Net Amount";
                        if POSSales.Quantity <> 0 then
                            POSSales."Net Price Excl Tax" := POSSales."Total Excl Tax" / POSSales.Quantity;

                        POSSales.Cost := POSSales."Net Amount" - POSSales."Consignment Amount";
                        POSSales."Cost Incl Tax" := POSSales.Cost + ((POSSales.Cost * POSVAT."VAT %") / 100); //UAT-025:Cost Inc Tax :=No9+No.11
                        getMDR(SalesEntry, possales."MDR Rate", possales."MDR Weight", possales."MDR Amount");
                        POSSales."MDR Rate Pctg" := possales."MDR Rate" * 100;
                        POSSales."Contract ID" := pContract;
                        if pVendor <> '' then begin
                            if POSSales."Vendor No." = pVendor then begin
                                POSSales.Insert()
                            end;
                        end else begin
                            POSSales.Insert();
                        end;
                        nextLineNo += 1;
                    until SalesEntry.Next() = 0;
            until LRecCNS.next = 0;
        end;
        // TransHeader.Reset();
        // TransHeader.SetCurrentKey("Store No.", Date);
        // if (pStoreNo <> '') then
        //     TransHeader.SetRange("Store No.", pStoreNo);
        // TransHeader.SetRange(Date, pStartDate, pEndDate);
        // TransHeader.SetFilter("Entry Status", '0|2');
        // TransHeader.SetLoadFields(Date, "Entry Status", "Posted Statement No.", "Member Card No.", "Trans. Currency");
        // if TransHeader.FindSet() then begin
        //     if GuiAllowed then begin
        //         Dialog.Open('Processing ' + 'Transaction' + ' #1########## of #2##########\');
        //         Dialog.update(2, format(TransHeader.Count));
        //     end;
        //     TransHeader.SetLoadFields("Posted Statement No.");
        //     repeat
        //         i += 1;
        //         if GuiAllowed then Dialog.update(1, format(i));


        //     until TransHeader.Next() = 0;
        //     if GuiAllowed then
        //         Dialog.Close();
        // end;
    end;
    #Region "Old Code"
    // procedure CalcConsignment(pVendNo: Code[20]; pDateValid: Date; xpPOSSales: Record "Consignment Entries"; var RtnConsignType: Code[20])
    // var
    //     ConsignStp: Record "Consignment Setup";
    //     pPOSSales: Record "Consignment Entries" temporary;
    //     intLineNo: Integer;
    // begin
    //     // pPOSSales.Reset();
    //     Clear(pPOSSales);
    //     pPOSSales.Reset();
    //     pPOSSales.Init();
    //     pPOSSales := xpPOSSales;
    //     //pPOSSales.Copy(xpPOSSales);
    //     pPOSSales.Insert();

    //     Clear(RtnConsignType);

    //     // if (pPOSSales."Periodic Offer No." <> '') or (pPOSSales."Promotion No." <> '') then begin
    //     //     ConsignStp.Reset();
    //     //     ConsignStp.SetRange("Vendor No.", pVendNo);
    //     //     ConsignStp.SetRange("Starting Date", 0D, pDateValid);
    //     //     ConsignStp.SetFilter("Ending Date", '>=%1|%2', pDateValid, 0D);
    //     //     if pPOSSales."Promotion No." <> '' then
    //     //         ConsignStp.SetRange("Promotion No.", pPOSSales."Promotion No.")
    //     //     else
    //     //         ConsignStp.SetFilter("Promotion No.", '''''');
    //     //     if pPOSSales."Periodic Offer No." <> '' then
    //     //         ConsignStp.SetRange("Periodic Discount Offer", pPOSSales."Periodic Offer No.")
    //     //     else
    //     //         ConsignStp.SetFilter("Periodic Discount Offer", '''''');
    //     //     ConsignStp.setrange("Sub Type", pPOSSales."Item No.");
    //     //     if not ConsignStp.FindFirst() then begin
    //     //         pPOSSales."Periodic Offer No." := '';
    //     //         pPOSSales."Promotion No." := '';
    //     //         pPOSSales.Modify();
    //     //     end;
    //     // end;

    //     ConsignStp.Reset();
    //     ConsignStp.SetRange("Vendor No.", pVendNo);
    //     ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::Item);
    //     ConsignStp.SetRange("Starting Date", 0D, pDateValid);
    //     ConsignStp.SetFilter("Ending Date", '>=%1|%2', pDateValid, 0D);
    //     if pPOSSales."Promotion No." <> '' then
    //         ConsignStp.SetRange("Promotion No.", pPOSSales."Promotion No.")
    //     else
    //         ConsignStp.SetFilter("Promotion No.", '');
    //     if pPOSSales."Periodic Offer No." <> '' then
    //         ConsignStp.SetRange("Periodic Discount Offer", pPOSSales."Periodic Offer No.")
    //     else
    //         ConsignStp.SetFilter("Periodic Discount Offer", '');
    //     //20240513-
    //     if pPOSSales."Total Discount" <> '' then
    //         ConsignStp.SetFilter("Total Discount", pPOSSales."Total Discount")
    //     else
    //         ConsignStp.SetFilter("Total Discount", '');
    //     //20240513+
    //     if ConsignStp.FindSet() then begin
    //         repeat
    //             if ConsignStp."Sub Type" = pPOSSales."Item No." then
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") then //20240513+ 
    //                     RtnConsignType := ConsignStp."Consignment Type";
    //         until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //     end;
    //     //20240513-
    //     if RtnConsignType = '' then begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::"Special Group 2");
    //         if ConsignStp.FindSet() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") //20240513+
    //                  then
    //                     if ConsignStp."Sub Type" = pPOSSales."Special Group 2" then
    //                         RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    //     //20240513+
    //     if RtnConsignType = '' then begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::"Special Group");
    //         if ConsignStp.FindSet() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer") then
    //                     if (ConsignStp."Sub Type" = pPOSSales."Special Group") and
    //                     (pPOSSales."Total Discount" = ConsignStp."Total Discount") then//20240513+  
    //                         RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    //     if RtnConsignType = '' then begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::"Product Group");
    //         if ConsignStp.FindFirst() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") //20240513+
    //                 then
    //                     if ConsignStp."Sub Type" = pPOSSales."Product Group" then
    //                         RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    //     if RtnConsignType = '' then begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::"Item Category");
    //         if ConsignStp.FindFirst() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") //20240513+
    //                  then
    //                     if ConsignStp."Sub Type" = pPOSSales."Item Category" then
    //                         RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    //     IF RtnConsignType = '' THEN begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::Division);
    //         if ConsignStp.FindFirst() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") //20240513+
    //                 then
    //                     if ConsignStp."Sub Type" = pPOSSales.Division then
    //                         RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    //     IF RtnConsignType = '' THEN begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::All);
    //         if ConsignStp.FindFirst() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount") //20240513+
    //                  then
    //                     RtnConsignType := ConsignStp."Consignment Type";
    //             until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //         end;
    //     end;
    // end;
    #EndRegion "Old Code"

    local procedure CalcConsignPerc(pPosSales: Record "Consignment Entries"; pContract: code[20]): Decimal
    var
        ConsignRate: Record "WP Consignment Margin Setup";
        //recRate: Record "Consignment Rate";
        intConsignRate: Decimal;
    begin
        Clear(intConsignRate);
        //withStoreCode
        ConsignRate.Reset();
        ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
        ConsignRate.SetFilter("Start Date", '<=%1', pPosSales.Date);
        ConsignRate.SetFilter("End Date", '>=%1', pPosSales.Date);
        ConsignRate.SetRange("Item No.", pPosSales."Item No.");
        ConsignRate.SetRange("Contract ID", pContract);
        //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
        ConsignRate.SetRange("Store No.", pPosSales."Store No.");
        if ConsignRate.FindFirst() then begin
            repeat
                if (ConsignRate."Disc. From" <= ABS(pPosSales."Discount %")) and (ConsignRate."Disc. To" >= ABS(pPosSales."Discount %")) then
                    intConsignRate := ConsignRate."Profit Margin";
            until (ConsignRate.next = 0) or (intConsignRate <> 0);
        end;


        //WithoutStoreCode
        if intConsignRate = 0 then begin
            ConsignRate.Reset();
            ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
            ConsignRate.SetFilter("Start Date", '<=%1', pPosSales.Date);
            ConsignRate.SetFilter("End Date", '>=%1', pPosSales.Date);
            ConsignRate.setrange("Item No.", pPosSales."Item No.");
            ConsignRate.SetRange("Contract ID", pContract);
            //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
            ConsignRate.SetFilter("Store No.", '');
            if ConsignRate.FindFirst() then begin
                repeat
                    if (ConsignRate."Disc. From" <= ABS(pPosSales."Discount %")) and (ConsignRate."Disc. To" >= ABS(pPosSales."Discount %")) then
                        if ConsignRate."Store No." = '' then
                            intConsignRate := ConsignRate."Profit Margin";
                until (ConsignRate.next = 0) or (intConsignRate <> 0);
            end;
        end;
        exit(intConsignRate);

        // recRate.Reset();
        // recRate.SetRange("Vendor No.", pPosSales."Vendor No.");
        // recRate.SetRange("Starting Date", 0D, pPosSales.Date);
        // recRate.SetFilter("Ending Date", '>=%1|%2', pPosSales.Date, 0D);
        // recRate.SetRange("Consignment Type", pPosSales."Consignment Type");
        // recRate.SetRange("Store No.", pPosSales."Store No.");
        // if recRate.FindLast() then
        //     exit(recRate."Consignment %");

    end;

    local procedure CalcConsignPerc_all(pPosSales: Record "Consignment Entries"): Decimal
    var
        ConsignRate: Record "WP Consignment Margin Setup";
        //recRate: Record "Consignment Rate";
        intConsignRate: Decimal;
    begin
        Clear(intConsignRate);
        //withStoreCode
        ConsignRate.Reset();
        ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
        ConsignRate.SetFilter("Start Date", '<=%1', pPosSales.Date);
        ConsignRate.SetFilter("End Date", '>=%1', pPosSales.Date);
        ConsignRate.SetRange("Item No.", pPosSales."Item No.");
        //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
        ConsignRate.SetRange("Store No.", pPosSales."Store No.");
        if ConsignRate.FindFirst() then begin
            repeat
                if (ConsignRate."Disc. From" <= ABS(pPosSales."Discount %")) and (ConsignRate."Disc. To" >= ABS(pPosSales."Discount %")) then
                    intConsignRate := ConsignRate."Profit Margin";
            until (ConsignRate.next = 0) or (intConsignRate <> 0);
        end;


        //WithoutStoreCode
        if intConsignRate = 0 then begin
            ConsignRate.Reset();
            ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
            ConsignRate.SetFilter("Start Date", '<=%1', pPosSales.Date);
            ConsignRate.SetFilter("End Date", '>=%1', pPosSales.Date);
            ConsignRate.setrange("Item No.", pPosSales."Item No.");
            //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
            ConsignRate.SetFilter("Store No.", '');
            if ConsignRate.FindFirst() then begin
                repeat
                    if (ConsignRate."Disc. From" <= ABS(pPosSales."Discount %")) and (ConsignRate."Disc. To" >= ABS(pPosSales."Discount %")) then
                        if ConsignRate."Store No." = '' then
                            intConsignRate := ConsignRate."Profit Margin";
                until (ConsignRate.next = 0) or (intConsignRate <> 0);
            end;
        end;
        exit(intConsignRate);

        // recRate.Reset();
        // recRate.SetRange("Vendor No.", pPosSales."Vendor No.");
        // recRate.SetRange("Starting Date", 0D, pPosSales.Date);
        // recRate.SetFilter("Ending Date", '>=%1|%2', pPosSales.Date, 0D);
        // recRate.SetRange("Consignment Type", pPosSales."Consignment Type");
        // recRate.SetRange("Store No.", pPosSales."Store No.");
        // if recRate.FindLast() then
        //     exit(recRate."Consignment %");

    end;

    procedure GetVendorCode(TSE: Record "LSC Trans. Sales Entry"): Code[20]
    var
        LRecPP: Record "Price List Line";//"Purchase Price";
        LRecDG: Record "LSC Distribution Group Member";
        recItem: Record Item;
        LFound: boolean;
        LStore: text[250];
    begin
        lfound := false;
        //Store Search
        LRecPP.Reset();
        LRecPP.SetRange("Asset Type", LRecPP."Asset type"::Item);
        LRecPP.SetRange("Source Type", lrecpp."Source Type"::Vendor);
        LRecPP.SetRange("Asset No.", TSE."Item No.");
        LRecPP.SetFilter("Starting Date", '<=%1', TSE.Date);
        LRecPP.SetFilter("Ending Date", '>=%1', TSE.Date);
        LRecPP.SetLoadFields("Asset Type", "Source Type", "Asset No.", "Starting Date", "Ending Date", "Source No.");
        if LRecPP.FindLast() then
            // LFound := true;
            exit(LRecPP."Source No.");

        if LFound = false then begin
            lrecpp.Reset();
            LRecPP.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
            lrecpp.setrange("Asset Type", LRecPP."Asset type"::Item);
            lrecpp.setrange("Source Type", lrecpp."Source Type"::Vendor);
            lrecpp.setrange("Source No.", tse."Item No.");
            //lrecpp.SetAscending("Source No.", false);
            LRecPP.Ascending(false);
            lrecpp.SetLoadFields("Asset Type", "Source Type", "Source No.", "Starting Date", "Ending Date", "Source No.");
            if lrecpp.FindSet() then
                repeat
                    if lrecpp."Starting Date" <= tse.Date then
                        if (lrecpp."Ending Date" >= tse.date) or (lrecpp."Ending Date" = 0D) then begin
                            // lfound := true;
                            exit(lrecpp."Source No.");
                        end;
                until (lrecpp.next = 0) or (LFound = true);
        end;
        //Store Group Search

        if lfound = false then begin
            lrecdg.Reset();
            lrecdg.SetRange("Distrib. Loc. Code", tse."Store No.");
            if lrecdg.FindFirst() then
                repeat
                    if lstore = '' then
                        lstore := lrecdg."Group Code"
                    else
                        lstore := lstore + '|' + LRecDG."Group Code";
                until lrecdg.Next() = 0;

            if lstore <> '' then begin
                lrecpp.Reset();
                lrecpp.setrange("Asset Type", LRecPP."Asset type"::Item);
                lrecpp.setrange("Source Type", lrecpp."Source Type"::Vendor);
                lrecpp.setrange("Source No.", tse."Item No.");
                lrecpp.Setfilter("Starting Date", '<=%1', tse.Date);
                LRecPP.SetFilter("Ending Date", '>=%1', tse.Date);
                if lrecpp.FindLast() then
                    // lfound := true;
                    exit(LRecPP."Source No.");
            end;

            if (lstore <> '') and (LFound = false) then begin
                clear(lrecpp);
                LRecPP.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                lrecpp.setrange("Asset Type", LRecPP."Asset type"::Item);
                lrecpp.setrange("Source Type", lrecpp."Source Type"::Vendor);
                lrecpp.setrange("Asset No.", tse."Item No.");
                //lrecpp.SetAscending("Asset No.", false);
                LRecPP.Ascending(false);
                lrecpp.SetLoadFields("Asset Type", "Source Type", "Source No.", "Starting Date", "Ending Date", "Source No.");
                if lrecpp.FindFirst() then begin
                    repeat
                        if lrecpp."Starting Date" <= tse.Date then
                            if (lrecpp."Ending Date" >= tse.date) or (lrecpp."Ending Date" = 0D) then begin
                                // lfound := true;
                                exit(LRecPP."Source No.")
                            end;
                    until (lrecpp.next = 0) or (LFound = true);
                end;
            end;

        end;
        //Blank Store Group Search
        if lfound = false then begin
            clear(lrecpp);
            lrecpp.setrange("Asset Type", LRecPP."Asset type"::Item);
            lrecpp.setrange("Source Type", lrecpp."Source Type"::Vendor);
            lrecpp.setrange("Asset No.", tse."Item No.");
            lrecpp.Setfilter("Starting Date", '<=%1', tse.Date);
            LRecPP.SetFilter("Ending Date", '>=%1', tse.Date);
            lrecpp.SetLoadFields("Asset Type", "Source Type", "Source No.", "Starting Date", "Ending Date", "Source No.");
            if lrecpp.FindLast() then
                exit(LRecPP."Source No.");

            if LFound = false then begin
                clear(lrecpp);
                LRecPP.SetCurrentKey("Asset Type", "Asset No.", "Source Type", "Source No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                lrecpp.setrange("Asset Type", LRecPP."Asset type"::Item);
                lrecpp.setrange("Source Type", lrecpp."Source Type"::Vendor);
                lrecpp.setrange("Asset No.", tse."Item No.");
                //lrecpp.SetAscending("Asset No.", false);
                LRecPP.Ascending(false);
                lrecpp.SetLoadFields("Asset Type", "Source Type", "Source No.", "Starting Date", "Ending Date", "Source No.");
                if lrecpp.FindFirst() then begin
                    repeat
                        if lrecpp."Starting Date" <= tse.Date then
                            if (lrecpp."Ending Date" >= tse.date) or (lrecpp."Ending Date" = 0D) then begin
                                // LFound := true;
                                exit(LRecPP."Source No.");
                            end;
                    until (lrecpp.next = 0) or (LFound = true);
                end;
            end;
        end;

        if LRecPP."Source No." = '' then begin
            recItem.reset();
            recItem.SetLoadFields("Vendor No.");
            if recItem.Get(TSE."Item No.") then
                exit(recItem."Vendor No.");
        end else
            exit(lrecpp."Source No.");
    end;

    procedure CreateInvoices(ce: Record "Consignment Entries"; startDate: date; endDate: date; SkipDuplicate: Boolean)
    var
        LRecCP: Record "Consignment Process Log";
        TRecVe: record "Item Journal Line" temporary;
        VendorTemp: record "Vendor" temporary;
        NextEntryNo: Integer;
        NextLineNo: Integer;
        PINo: code[20];
        SINo: code[20];
        LRecPH: record "Purchase Header";
        LRecPL: record "Purchase Line";
        LRecSH: record "Sales Header";
        LRecSL: record "Sales Line";
        LRecVen: Record Vendor;
        PRel: codeunit "Release Purchase Document";
        SRel: Codeunit "Release Sales Document";
        IsDuplicate: Boolean;
        TempPH: Record "Purchase Header" temporary;
        TempPL: Record "Purchase Line" temporary;
        TempSH: Record "Sales Header" temporary;
        TempSL: Record "Sales Line" temporary;
        TempDocNo: Integer;
        i: integer;
        LogVendorNo: code[20];
        LogCustomerNo: code[20];
        MonthText: Text[3];
        InvertedComma: char;
        linefilter: text[250];
    begin
        if RetailSetup.Get() then;
        RetailSetup.TestField("Def. Purch. Inv. G/L Acc.");
        RetailSetup.TestField("Def. Sales Inv. G/L Acc.");

        ce.reset;
        ce.SetRange("USER SID", UserSecurityId);
        if ce.Findset() then begin
            repeat
                VendorTemp.Reset();
                if not VendorTemp.Get(ce."Vendor No.") then begin
                    VendorTemp."No." := ce."Vendor No.";
                    clear(LRecVen);
                    if lrecven.get(ce."Vendor No.") then;
                    VendorTemp."Linked Customer No." := lrecven."Linked Customer No.";
                    VendorTemp.Insert();
                end;
                clear(linefilter);
                linefilter := 'GROUP T' + format(ce."Tax Rate") + 'M' + format(ce."Consignment %");
                trecve.reset;
                trecve.setrange("Journal Batch Name", 'temp');
                trecve.setrange("Journal Template Name", 'item');
                trecve.setrange("Source Type", TRecVe."Source Type"::Vendor);
                trecve.setrange("Source No.", ce."Vendor No.");
                trecve.setrange("Location Code", ce."Store No.");
                trecve.setrange(Description, linefilter);
                if TRecVe.FindFirst() then begin
                    //trecve."Unit Cost" += ce."Net Amount";
                    trecve."Unit Cost" += ce.Cost;
                    //trecve."Unit Cost (ACY)" += ce."Consignment Amount (LCY)";
                    TRecVe."Unit Amount" += ce."Total Tax Collected";
                    trecve.modify;
                end else begin
                    NextEntryNo += 1000;
                    trecve."Journal Batch Name" := 'temp';
                    trecve."Journal Template Name" := 'item';
                    trecve."Line No." := NextEntryNo;
                    TRecVe."Item No." := ce."Item No.";
                    TRECVE.Description := linefilter;
                    trecve."Source Type" := trecve."Source Type"::Vendor;
                    trecve."source No." := ce."Vendor No.";
                    trecve."Location Code" := ce."Store No.";
                    trecve.Quantity := 1;
                    //TRecVe."Unit Cost" := ce."Net Amount";
                    //TRECVE."Unit Cost" := CE."Net Amount" - CE."VAT Amount";
                    TRECVE."Unit Cost" := CE.Cost;
                    TRecVe.VALIDATE("Unit Cost");
                    //trecve."Unit Cost (ACY)" := ce."Consignment Amount (LCY)";
                    //TRecVe."Unit Amount" := ce."Total Tax Collected";
                    TRecVe.insert;
                end;
            until ce.next = 0;
        end;

        TempDocNo := 0;
        VendorTemp.Reset();
        if VendorTemp.FindFirst() then begin
            repeat
                IsDuplicate := false;
                //createheader-
                clear(LRecCP);
                LRecCP.SetRange("Vendor No.", VendorTemp."No.");
                LRecCP.SetFilter("Starting Date", '<=%1', startDate);
                LRecCP.SetFilter("Ending Date", '>=%1', endDate);
                if LRecCP.FindFirst() then begin
                    isduplicate := true;
                    if SkipDuplicate = false then
                        if GuiAllowed = true then
                            if Confirm('Invoice previously already created; Do you want to create again?') = false then
                                break
                            else
                                IsDuplicate := false;
                end;

                if not isduplicate then begin
                    TempDocNo += 1;
                    //Insert Temp Header-
                    clear(TempPH);
                    TempPH."No." := format(TempDocNo);
                    TempPH."Document Type" := TempPH."Document Type"::Invoice;
                    TempPH."Buy-from Vendor No." := VendorTemp."No.";
                    TempPH.Validate("Buy-from Vendor No.", VendorTemp."No.");
                    TempPH."Document Date" := today;
                    // TempPH."Posting Date" := today;
                    TempPH."Posting Date" := CalcDate('CM', endDate);
                    TempPH."Your Reference" := 'CONSIGN';//20201109
                    if TempPH.insert() then;

                    //createline
                    trecve.reset;
                    trecve.setrange("Journal Batch Name", 'temp');
                    trecve.setrange("Journal Template Name", 'item');
                    trecve.setrange("Source No.", VendorTemp."No.");
                    if trecve.FindFirst() then begin
                        repeat
                            //Insert Temp PL Lines-
                            TempPL.Reset;
                            TempPL.setrange("Document Type", TempPL."Document Type"::Invoice);
                            TempPL.setrange("Document No.", format(TempDocNo));
                            if TempPL.FindLast() then
                                NextLineNo := temppl."Line No." + 1000
                            else
                                NextLineNo := 1000;

                            clear(TempPL);
                            TempPL."Document Type" := TempPL."Document Type"::Invoice;
                            TempPL."Document No." := format(TempDocNo);
                            TempPL."Line No." := NextLineNo;
                            TempPL.Type := lrecpl.type::"G/L Account";
                            TempPL."No." := RetailSetup."Def. Purch. Inv. G/L Acc.";
                            if trecve."Location Code" <> '' then begin
                                TempPL."Location Code" := trecve."Location Code";
                                TempPL."Shortcut Dimension 1 Code" := TRecVe."Location Code";
                            end;
                            TempPL.Quantity := 1;
                            TempPL."Direct Unit Cost" := trecve."Unit Cost";
                            TempPL.Amount := TRecVe."Unit Amount";
                            temppl.Description := TRecVe.Description;
                            TempPL.insert();

                        until trecve.next = 0;
                    end;

                end;
            //CreateLog+
            until VendorTemp.Next() = 0;
        end;

        if TempDocNo <> 0 then begin
            for i := 1 to TempDocNo DO begin
                //Convert Purchase Temp-
                TempPH.reset;
                tempph.SetRange("No.", format(i));
                if tempph.findfirst then begin
                    clear(LRecPH);
                    lrecph."Document Type" := TempPH."Document Type";
                    lrecph."Buy-from Vendor No." := TempPH."Buy-from Vendor No.";
                    lrecph.Validate("Buy-from Vendor No.", tempph."Buy-from Vendor No.");
                    LogVendorNo := TempPH."Buy-from Vendor No.";
                    lrecph."Document Date" := TempPH."Document Date";
                    lrecph."Posting Date" := TempPH."Posting Date";
                    LRECPH."Your Reference" := 'CONSIGN';//20201109
                    Clear(MonthText);
                    case Format(LRecPH."Posting Date", 0, '<Month,2>') of
                        '01':
                            MonthText := 'JAN';
                        '02':
                            MonthText := 'FEB';
                        '03':
                            MonthText := 'MAR';
                        '04':
                            MonthText := 'APR';
                        '05':
                            MonthText := 'MAY';
                        '06':
                            MonthText := 'JUN';
                        '07':
                            MonthText := 'JUL';
                        '08':
                            MonthText := 'AUG';
                        '09':
                            MonthText := 'SEP';
                        '10':
                            MonthText := 'OCT';
                        '11':
                            MonthText := 'NOV';
                        '12':
                            MonthText := 'DEC';
                    end;
                    InvertedComma := 39;
                    if lrecph.insert(True) then begin
                        pino := lrecph."No.";
                        lrecph.validate("Document Date", TempPH."Posting Date");
                        LRecPH.Validate("Posting Date", TempPH."Posting Date");
                        LRecPH."Posting Description" := 'CONSIGN SALES ' + MonthText + InvertedComma + Format(LRecPH."Posting Date", 0, '<Year,2>');
                        LRecPH.Modify();
                    end;

                    TempPL.reset;
                    temppl.SetRange("Document No.", TempPH."No.");
                    if temppl.findfirst then
                        repeat
                            clear(LRecPL);
                            lrecpl."Document Type" := temppl."Document Type";
                            lrecpl.validate("Document No.", pino);
                            lrecpl."Line No." := temppl."Line No.";
                            lrecpl.Type := temppl.Type;
                            lrecpl.validate("No.", temppl."No.");
                            if trecve."Location Code" <> '' then begin
                                lrecpl.validate("Location Code", temppl."Location Code");
                                lrecpl.validate("Shortcut Dimension 1 Code", temppl."Shortcut Dimension 1 Code");
                            end;
                            lrecpl.validate(Quantity, 1);
                            lrecpl.validate("Direct Unit Cost", TempPL."Direct Unit Cost");
                            lrecpl.Description := TempPL.Description;
                            lrecpl.insert(true);

                            //B2B Enhancement-
                            if TempPL.Amount <> 0 then begin
                                clear(LRecPL);
                                lrecpl."Document Type" := temppl."Document Type";
                                lrecpl.validate("Document No.", pino);
                                lrecpl."Line No." := temppl."Line No." + 500;
                                lrecpl.Type := temppl.Type;
                                lrecpl.validate("No.", temppl."No.");
                                LRecPL.Description := LRecPL.Description + '-SST';
                                if trecve."Location Code" <> '' then begin
                                    lrecpl.validate("Location Code", temppl."Location Code");
                                    lrecpl.validate("Shortcut Dimension 1 Code", temppl."Shortcut Dimension 1 Code");
                                end;
                                lrecpl.validate(Quantity, 1);
                                lrecpl.validate("Direct Unit Cost", abs(TempPL.Amount));
                                lrecpl.Description := TempPL.Description;
                                lrecpl.insert(true);
                            end;
                        //B2B Enhancement+
                        until temppl.next = 0;
                end;
                //Convert Purchase Temp+

                clear(LRecCP);
                if lreccp.FindLast() then
                    NextEntryNo := lreccp."Entry No." + 1
                else
                    NextEntryNo := 1;

                clear(LRecCP);
                LRecCP.Reset();
                LRecCP."Entry No." := NextEntryNo;
                LRecCP."Vendor No." := LogVendorNo;
                LRecCP."Customer No." := LogCustomerNo;
                LRecCP."Purchase Invoice No." := pino;
                LRecCP."Sales Invoice No." := sino;
                LRecCP."Starting Date" := startDate;
                LRecCP."Ending Date" := endDate;
                LRecCP."Email Address" := GetEMailAddress(LRecCP."Vendor No.");
                LRecCP."Created By" := userid;
                LRecCP."Created Datetime" := CurrentDateTime;
                LRecCP.CEPath := RetailSetup."Consignment Attachment Path" + '\ConsignmentReport_' + LogVendorNo + FORMAT(endDate, 0, '<Year,2><Month,2>') + FORMAT(LRecCP."Entry No.") + '.PDF';
                //CEReport-
                Clear(ce);
                ce.SetRange("Created By", userid);
                ce.setrange("Vendor No.", LogVendorNo);
                ce.setrange(Date, startDate, endDate);
                if ce.FindFirst() then begin
                    if RetailSetup.get then
                        RetailSetup.TestField("Consignment Attachment Path");
                end;
                //CEReport+ 
                LRecCP."Email Sent" := false;
                LRecCP.Insert();

            end;
        end;
    end;

    local procedure GetEMailAddress(LVendorCode: Code[20]): Text[80]
    var
        LVendor: Record vendor;
    begin
        if LVendorCode = '' then exit('');
        LVendor.Reset();
        LVendor.SetRange("No.", LVendorCode);
        LVendor.SetLoadFields("E-Mail");
        if LVendor.FindFirst() then
            exit(LVendor."E-Mail");
    end;

    procedure CheckUnsentEmail()
    var
        LRecCL: Record "Consignment Process Log";
        FileMgt: Codeunit "File Management";
        LFilePath: text[250];
        LFileName: text[250];
        ZipFilePath: text[250];
        Email: Codeunit "Document-Mailing";
        TempFilePath: text;
        i: Integer;
        RptEmail: Report "Consignment E-Mail Body";
        LRecCL2: Record "Consignment Process Log";
    begin
        RetailSetup.Reset();
        if RetailSetup.Get() then
            RetailSetup.TestField("Consignment Attachment Path");

        i := 0;
        LRecCL.Reset();
        lreccl.setrange("Email Sent", false);
        lreccl.SetFilter("Email Address", '<>%1', '');
        LRecCL.SetRange(B2B, false);
        if LRecCL.FindFirst() then begin
            repeat
                if lreccl."Email Address" <> '' then begin
                    // if file.exists(lreccl.CEPath) then begin //Obsolete
                    LFileName := CopyStr(LRecCL.CEPath, StrLen(RetailSetup."Consignment Attachment Path") + 2);
                    //LFileName := lreccl."Vendor No." + format(lreccl."Starting Date", 0, '<Year,2><Month,2>') + '.ZIP';
                    LFilePath := RetailSetup."Consignment Attachment Path" + '\' + LFileName;

                    //Temporary Close-
                    // zipfilepath := FileMgt.CreateZipArchiveObject();
                    // // FileMgt.AddFileToZipArchive(lreccl.PIPath, 'PINV.' + lreccl."Vendor No." + '.' + lreccl."Purchase Invoice No." + '.pdf');//20201109
                    // // FileMgt.AddFileToZipArchive(lreccl.SIPath, 'SINV.' + lreccl."Customer No." + '.' + lreccl."Sales Invoice No." + '.pdf');//20201109
                    // FileMgt.AddFileToZipArchive(lreccl.CEPath, 'CENT.' + LRECCL."Vendor No." + '.' + FORMAT(LRECCL."Starting Date", 0, '<Year,2><Month,2>') + '.pdf');
                    // FileMgt.CloseZipArchive();
                    // FileMgt.CopyServerFile(ZipFilePath, LFilePath, true);
                    //Temporary Close+

                    clear(TempFilePath); //03032022 enhance logic prevent duplicate email body
                                         // TempFilePath := FileMgt.ServerTempFileName('html'); //Obsolete
                                         // Report.SaveAsHtml(70002, TempFilePath, lreccl);

                    //03032022 enhance logic prevent duplicate email body-
                    Clear(LRecCL2);
                    LRecCL2.Reset();
                    LRecCL2.SetRange("Entry No.", LRecCL."Entry No.");
                    if LRecCL2.FindFirst() then;

                    // Report.SaveAsHtml(70002, TempFilePath, LRecCL2); //Obsolete
                    // Clear(RptEmail);
                    // RptEmail.SetTableView(LRecCL2);
                    // RptEmail.SaveAsHtml(TempFilePath);
                    //03032022 enhance logic prevent duplicate email body+

                    // lreccl."Email Sent" := email.EmailFile(lfilepath, LFileName, TempFilePath, '', lreccl."Email Address", 'Monthly Consignment Sales Report', true, 0);//20201109 SubjectChanged //Obsolete
                    lreccl.Modify;

                    if lreccl."Email Sent" then begin
                        // FileMgt.DeleteServerFile(TempFilePath); //Obsolete
                        // filemgt.DeleteServerFile(ZipFilePath);
                        // FileMgt.DeleteServerFile(LFilePath);
                    end;
                end else begin
                    i += 1;
                end;
            // end;

            until lreccl.next = 0;
            if i > 0 then
                Message(StrSubstNo('%1 of email did not send out successfully.'), Format(i));
        end;
    end;

    local procedure InitFolder()
    var
        FileMgmt: Codeunit "File Management";
    begin
        RetailSetup.Reset();
        if RetailSetup.Get() then
            RetailSetup.TestField("Consignment Attachment Path");
    end;

    local procedure GenPDFInvoice(NewPurchHeader: Record "Purchase Header"; NewSalesHeader: Record "Sales Header"; IsPurch: Boolean): text
    var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReportSelection: record "Report Selections";
        FileMgmt: Codeunit "File Management";
        ServerTmpPath: text;
    begin
        InitFolder();
        if RetailSetup.Get() then
            RetailSetup.TestField("Consignment Attachment Path");

        if IsPurch = true then begin
            PurchHeader := NewPurchHeader;
            PurchHeader.SETRECFILTER;

            PurchSetup.GET;
            IF PurchSetup."Calc. Inv. Discount" THEN BEGIN
                PurchLine.RESET;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine.FINDFIRST;
                CODEUNIT.RUN(CODEUNIT::"Purch.-Calc.Discount", PurchLine);
                PurchHeader.GET(PurchHeader."Document Type", PurchHeader."No.");
                COMMIT;
            END;

            clear(ReportSelection);
            ReportSelection.setrange(usage, ReportSelection.Usage::"P.Test");
            if ReportSelection.FindFirst() then begin
                ServerTmpPath := RetailSetup."Consignment Attachment Path" + '\PI_' + PurchHeader."Buy-from Vendor No." + '_' + PurchHeader."No." + '.PDF';
                // if FileMgmt.ServerFileExists(ServerTmpPath) = true then FileMgmt.DeleteServerFile(ServerTmpPath); //Obsolete
                //ServerTmpPath := FileMgmt.ServerTempFileName('pdf');
                // report.SaveAsPdf(ReportSelection."Report ID", ServerTmpPath, PurchHeader); //Obsolete
                exit(ServerTmpPath);
            end;
        end else begin
            SalesHeader := NewSalesHeader;
            SalesHeader.SETRECFILTER;
            SalesSetup.GET;
            IF SalesSetup."Calc. Inv. Discount" THEN BEGIN
                SalesLine.RESET;
                SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                SalesLine.FINDFIRST;
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", SalesLine);
                SalesHeader.GET(SalesHeader."Document Type", SalesHeader."No.");
                COMMIT;
            END;

            clear(ReportSelection);
            ReportSelection.setrange(Usage, ReportSelection.Usage::"S.Test");
            if ReportSelection.FindFirst() then begin
                ServerTmpPath := RetailSetup."Consignment Attachment Path" + '\SI_' + SalesHeader."Sell-to Customer No." + '_' + SalesHeader."No." + '.PDF';
                // if FileMgmt.ServerFileExists(ServerTmpPath) = true then FileMgmt.DeleteServerFile(ServerTmpPath); //Obsolete
                //ServerTmpPath := FileMgmt.ServerTempFileName('pdf');
                // report.SaveAsPdf(ReportSelection."Report ID", ServerTmpPath, SalesHeader); //Obsolete
                exit(ServerTmpPath);
            end;
        end;
        exit('');
    end;

    procedure GetConsignPostGroup(): text[250]
    begin
        if RetailSetup.Get() then
            exit(RetailSetup."Consign. Prod. Posting Groups");
    end;

    procedure TestPDF()
    var
        Hdr: Record "Purchase Header";
        Sdr: record "Sales Header";
        ConsignmentPRocessLog: record "Consignment Process Log";
    begin
        if ConsignmentPRocessLog.FindFirst() then
            ConsignmentPRocessLog.DeleteAll();

        // cl."Entry No." := 1;
        // cl."Vendor No." := 'V00030';
        // cl."Purchase Invoice No." := '1002';
        // cl."Customer No." := '10000';
        // cl."Sales Invoice No." := '1029';
        // cl.PIPath := 'C:\LS\PI_V00030_1002.PDF';
        // cl.SIPath := 'C:\LS\SI_10000_1029.PDF';
        // cl.CEPath := 'C:\LS\ABC.PDF';
        // cl."Email Address" := 'eddy.ong@rgtech.com.my';
        // cl."Starting Date" := today;
        // cl."Ending Date" := today;
        // cl.insert;

        // cl.setrange("Email Sent", true);
        // if cl.FindFirst() then begin
        //     repeat
        //         cl."Email Sent" := false;
        //         cl.modify;
        //     until cl.next = 0;
        // end;
        // CheckUnsentEmail();

        // clear(hdr);
        // hdr.setrange("Document Type", hdr."Document Type"::Invoice);
        // hdr.setrange("No.", '1002');
        // if hdr.FindFirst() then
        //     message(GenPDFInvoice(hdr, Sdr, true));

        // clear(sdr);
        // sdr.setrange("Document Type", sdr."Document Type"::Invoice);
        // sdr.setrange("No.", '1029');
        // if sdr.FindFirst() then
        //     message(GenPDFInvoice(hdr, Sdr, false));

    end;

    procedure DeleteSalesDateByDocument(DocNo: code[20]; pContract: code[20])
    var
        POSSalesEntry: Record "Consignment Entries";
        be: Record "Consignment Billing Entries";
    begin
        clear(POSSalesEntry);
        POSSalesEntry.Reset();
        POSSalesEntry.SetRange("Document No.", DocNo);
        POSSalesEntry.SetRange("Contract ID", pContract);
        POSSalesEntry.deleteall;

        clear(be);
        be.reset;
        be.setrange("Document No.", docno);
        be.setrange("Contract ID", pContract);
        be.deleteall;
    end;

    procedure DeleteSalesDateByDocument_ALL(DocNo: code[20])
    var
        POSSalesEntry: Record "Consignment Entries";
        be: Record "Consignment Billing Entries";
    begin
        clear(POSSalesEntry);
        POSSalesEntry.Reset();
        POSSalesEntry.SetRange("Document No.", DocNo);
        POSSalesEntry.deleteall;

        clear(be);
        be.reset;
        be.setrange("Document No.", docno);
        be.deleteall;
    end;

    procedure CopySalesData2(pStartDate: Date; pEndDate: Date; pStoreNo: Code[10]; pVendor: code[20]; DocNo: code[20]; pContract: code[20]; pBillingID: code[20])
    var
        TransHeader: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        POSSales: Record "Consignment Entries";
        recItem: Record item;
        ItemSpecialGrp: Record "LSC Item/Special Group Link";
        Barc: Record "LSC barcodes";
        ValueEntry: Record "Value Entry";
        CurrExcRate: Record "Currency Exchange Rate";
        discPerc: Decimal;
        ckDiscount: Decimal;
        ValueEntryQty: Decimal;
        CostAmountActual: Decimal;
        CostPerUnit: Decimal;
        ConsignGroup: text[250];//20200923
        StoreVendor: code[20];//20201002
        POSVAT: Record "LSC POS VAT Code";
        i: Integer; //20210705
        gdiag: Dialog; //20210705
        //recCS: record "Consignment Setup";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        NextLineNo: Integer;
        ConsignRate: Record "WP Consignment Margin Setup";
        MGPSetup: Record "WP MPG Setup";
        ConsigPerc: Decimal;
        DiscPercSaleEntry: Decimal;
        AllowanceDiscAmt: Decimal;
        NetAllowanceAmt: decimal;
        VatAllowanceAmt: decimal;
        AllowanceDiscPerc: Decimal;
    begin
        //Get all vendor setup for specific time range
        POSSales.Reset();
        POSSales.SetRange("Document No.", DocNo);
        POSSales.SetLoadFields("Line No.");
        if POSSales.FindLast() then
            NextLineNo := POSSales."Line No." + 100
        else
            NextLineNo := 100;

        i := 0;
        recitem.Reset();
        recitem.setrange("Vendor No.", pVendor);
        //recitem.setrange("Gen. Prod. Posting Group", GetConsignPostGroup());
        recItem.SetFilter("Gen. Prod. Posting Group", GetConsignPostGroup());
        recitem.SetLoadFields("Vendor No.", "Gen. Prod. Posting Group", "LSC Item Family Code", Description, "LSC Division Code");
        if recitem.FindSet() then begin
            if GuiAllowed then gdiag.open('Processing ' + 'Item(s)' + ' #1########## of #2##########\');
            if GuiAllowed then gdiag.update(2, format(recItem.Count));
            repeat
                i += 1;
                if GuiAllowed then gdiag.update(1, format(i));
                SalesEntry.Reset();
                SalesEntry.setrange(Date, pStartDate, pEndDate);
                SalesEntry.SetRange("Item No.", recItem."No.");
                if SalesEntry.FindSet() then begin

                    repeat
                        //withStoreCode
                        ConsignRate.Reset();
                        ConsignRate.SetRange("Vendor No.", pVendor);
                        ConsignRate.SetRange("Item No.", SalesEntry."Item No.");
                        ConsignRate.SetRange("Contract ID", pContract);
                        clear(POSVAT);
                        POSVAT.reset;
                        IF POSVAT.Get(SalesEntry."VAT Code") then;
                        /*  IF (SalesEntry."wp Member Disc. %" <> 0) OR (SalesEntry."wp Staff Disc. %" <> 0) then begin
                              SalesEntry."Discount Amount" := SalesEntry."Discount Amount" - (SalesEntry."wp Member Disc. Amount" + SalesEntry."wp Staff Disc. Amount");
                              SalesEntry."Discount %" := ROUND((SalesEntry."Discount Amount" / SalesEntry.Price * 100), 1);
                              IF SalesEntry."Total Rounded Amt." < 0 then begin
                                  SalesEntry."Total Rounded Amt." := SalesEntry."Total Rounded Amt." - (SalesEntry."wp Member Disc. Amount" + SalesEntry."wp Staff Disc. Amount");
                                  SalesEntry."Net Amount" := ROUND((SalesEntry."Total Rounded Amt.") / (1 + POSVAT."VAT %" / 100), 1);
                                  SalesEntry."VAT Amount" := SalesEntry."Total Rounded Amt." - SalesEntry."Net Amount";

                              end else begin
                                  SalesEntry."Total Rounded Amt." := SalesEntry."Total Rounded Amt." - (SalesEntry."wp Member Disc. Amount" + SalesEntry."wp Staff Disc. Amount");
                                  SalesEntry."Net Amount" := ROUND((SalesEntry."Total Rounded Amt.") / (1 + POSVAT."VAT %" / 100), 1);
                                  SalesEntry."VAT Amount" := SalesEntry."Total Rounded Amt." - SalesEntry."Net Amount";
                              end;


                          end;*/
                        //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
                        ConsignRate.SetRange("Store No.", SalesEntry."Store No.");
                        // SalesEntry."Discount %" := ROUND((SalesEntry."Discount Amount" / SalesEntry.Price * 100), 1);
                        SalesEntry."Discount %" := Round(SalesEntry."Discount %");
                        if ConsignRate.FindFirst() then begin
                            repeat
                                DiscPercSaleEntry := 0;
                                DiscPercSaleEntry := SalesEntry."Discount %";//Exclude allowance
                                if (ABS(DiscPercSaleEntry) >= ConsignRate."Disc. From") and (ABS(DiscPercSaleEntry) <= ConsignRate."Disc. To") then begin
                                    Clear(MGPSetup);

                                    MGPSetup.Reset();
                                    MGPSetup.SetRange("Vendor No.", pVendor);
                                    MGPSetup.SetRange("Contract ID", pContract);
                                    MGPSetup.SetRange("Billing Period ID", pBillingID);
                                    if MGPSetup.FindSet() then begin
                                        repeat

                                            clear(TransHeader);
                                            TransHeader.SetCurrentKey("Receipt No.");
                                            TransHeader.setrange("Receipt No.", SalesEntry."Receipt No.");
                                            TransHeader.SetLoadFields("Receipt No.", "Member Card No.", "Trans. Currency", "Entry Status");
                                            if TransHeader.FindFirst() then begin
                                                if (TransHeader."Entry Status" = 0) or (TransHeader."Entry Status" = 2) then begin
                                                    Clear(POSSales);
                                                    POSSales.Reset();
                                                    POSSales.Init();
                                                    POSSales."Document No." := DocNo;
                                                    POSSales."Line No." := NextLineNo;
                                                    POSSales."Transaction No." := SalesEntry."Transaction No.";
                                                    POSSales."Sales Entry Line No." := SalesEntry."Line No.";
                                                    POSSales."Receipt No." := SalesEntry."Receipt No.";
                                                    POSSales."POS Terminal No." := SalesEntry."POS Terminal No.";
                                                    POSSales.validate("Item No.", SalesEntry."Item No.");
                                                    POSSales.Date := SalesEntry.Date;
                                                    POSSales."Store No." := SalesEntry."Store No.";
                                                    POSSales."Vendor No." := pVendor;
                                                    POSSales."Item Family Code" := recitem."LSC Item Family Code";
                                                    POSSales.Division := recItem."LSC Division Code";
                                                    POSSales."Item Category" := SalesEntry."Item Category Code";
                                                    POSSales."Product Group" := SalesEntry."Retail Product Code";
                                                    POSSales."Item Description" := recItem.Description;
                                                    POSSales."Product Group Description" := getProductGroupDesc(recitem."No.");

                                                    Clear(ItemSpecialGrp);
                                                    ItemSpecialGrp.Reset();
                                                    ItemSpecialGrp.SetRange("Item No.", SalesEntry."Item No.");
                                                    if ItemSpecialGrp.FindFirst() then begin
                                                        repeat
                                                            if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'B' then
                                                                POSSales."Special Group" := ItemSpecialGrp."Special Group Code";

                                                            if CopyStr(ItemSpecialGrp."Special Group Code", 1, 1) = 'C' then
                                                                POSSales."Special Group 2" := ItemSpecialGrp."Special Group Code"
                                                            else
                                                                //Peter modified this to get special group without B and C
                                                                POSSales."Special Group" := ItemSpecialGrp."Special Group Code"

                                                        until ItemSpecialGrp.Next() = 0;

                                                    end;
                                                    if SalesEntry."Barcode No." <> '' then
                                                        POSSales."Barcode No." := SalesEntry."Barcode No."
                                                    else begin
                                                        Clear(Barc);
                                                        Barc.Reset();
                                                        Barc.SetRange("Item No.", SalesEntry."Item No.");
                                                        Barc.SetRange("Unit of Measure Code", SalesEntry."Unit of Measure");
                                                        if Barc.FindFirst() then
                                                            POSSales."Barcode No." := Barc."Barcode No.";
                                                    end;

                                                    clear(POSVAT);
                                                    POSVAT.reset;
                                                    if POSVAT.Get(SalesEntry."VAT Code") then;

                                                    POSSales.Quantity := -SalesEntry.Quantity;
                                                    POSSales.Price := SalesEntry.Price;
                                                    POSSales.UOM := SalesEntry."Unit of Measure";
                                                    POSSales."Net Amount" := -SalesEntry."Net Amount"; //Exclude allowance
                                                    POSSales."VAT Amount" := -SalesEntry."VAT Amount"; //Exclude allowance

                                                    //UAT-025: Fix Tax Rate always is 0 
                                                    POSSales."Tax Rate" := POSVAT."VAT %";
                                                    POSSales."VAT Prod. Posting Group" := SalesEntry."VAT Prod. Posting Group";
                                                    //end UAT-025
                                                    //POSSales."Discount Amount" := ((100 - posvat."VAT %") / 100) * SalesEntry."Discount Amount";
                                                    POSSales."Discount Amount" := SalesEntry."Discount Amount" / ((100 + POSVAT."VAT %") / 100); //Exclude allowance
                                                    POSSales."Promotion No." := SalesEntry."Promotion No.";
                                                    POSSales."Periodic Disc. Type" := SalesEntry."Periodic Disc. Type";
                                                    POSSales."Periodic Offer No." := SalesEntry."Periodic Disc. Group";

                                                    TransDiscEntry.Reset();
                                                    TransDiscEntry.SetRange("Receipt No.", SalesEntry."Receipt No.");
                                                    TransDiscEntry.SetRange("Transaction No.", SalesEntry."Transaction No.");
                                                    TransDiscEntry.SetRange("Store No.", SalesEntry."Store No.");
                                                    TransDiscEntry.SetRange("Line No.", SalesEntry."Line No.");
                                                    if TransDiscEntry.FindFirst() then begin
                                                        repeat
                                                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Line Discount") then begin
                                                                POSSales."Periodic Disc. Type" := POSSales."Periodic Disc. Type"::"Line Disc.";
                                                                POSSales."Periodic Offer No." := TransDiscEntry."Offer No.";
                                                            end;
                                                            if (TransDiscEntry."Offer Type" = TransDiscEntry."Offer Type"::"Total Discount") then begin
                                                                POSSales."Total Discount" := TransDiscEntry."Offer No.";
                                                            end;
                                                        until TransDiscEntry.Next() = 0;
                                                    end;

                                                    POSSales."Periodic Discount Amount" := SalesEntry."Periodic Discount";
                                                    POSSales."VAT Code" := SalesEntry."VAT Code";
                                                    POSSales."Return No Sales" := SalesEntry."Return No Sale";
                                                    POSSales."Cost Amount" := -SalesEntry."Cost Amount";
                                                    POSSales."USER SID" := USERSECURITYID;
                                                    POSSales."Session ID" := SESSIONID;
                                                    POSSales."Created By" := USERID;
                                                    POSSales."Created Date" := CURRENTDATETIME;
                                                    POSSales."Discount %" := SalesEntry."Discount %"; //Exclude allowance
                                                    //CalcConsignment(POSSales."Vendor No.", POSSales.Date, POSSales, POSSales."Consignment Type");
                                                    POSSales."Consignment %" := CalcConsignPerc(POSSales, MGPSetup."Contract ID");
                                                    IF POSSales."Consignment %" <> 0 THEN
                                                        POSSales."Consignment Amount" := ROUND(POSSales."Net Amount" * (POSSales."Consignment %" / 100)) //Profit Amount
                                                    ELSE
                                                        POSSales."Consignment Amount" := 0;

                                                    POSSales."Member Card No." := TransHeader."Member Card No.";
                                                    POSSales."Currency Code" := TransHeader."Trans. Currency";

                                                    IF POSSales."Currency Code" <> '' THEN BEGIN
                                                        Clear(CurrExcRate);
                                                        CurrExcRate.Reset();
                                                        CurrExcRate.SetRange("Currency Code", POSSales."Currency Code");
                                                        CurrExcRate.SetFilter("Starting Date", '<=%1', POSSales.Date);
                                                        if CurrExcRate.FindFirst() then
                                                            POSSales."Exch. Rate" := CurrExcRate."Relational Exch. Rate Amount";
                                                    end;
                                                    if POSSales."Exch. Rate" <> 0 then begin
                                                        POSSales."Net Amount (LCY)" := ROUND(POSSales."Net Amount" * POSSales."Exch. Rate", 1, '=');
                                                        POSSales."VAT Amount (LCY)" := ROUND(POSSales."VAT Amount" * POSSales."Exch. Rate", 1, '=');
                                                        POSSales."Discount Amount (LCY)" := Round(POSSales."Discount Amount (LCY)" * POSSales."Exch. Rate", 1, '=');
                                                        POSSales."Periodic Discount Amount (LCY)" := ROUND(POSSales."Periodic Discount Amount" * POSSales."Exch. Rate", 1, '=');
                                                        POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                                                        POSSales."Consignment Amount (LCY)" := ROUND(POSSales."Consignment Amount" * POSSales."Exch. Rate", 1, '=');
                                                    end else begin
                                                        POSSales."Net Amount (LCY)" := POSSales."Net Amount";
                                                        POSSales."VAT Amount (LCY)" := POSSales."VAT Amount";
                                                        POSSales."Discount Amount (LCY)" := POSSales."Discount Amount";
                                                        POSSales."Periodic Discount Amount (LCY)" := POSSales."Periodic Discount Amount";
                                                        POSSales."Cost Amount (LCY)" := POSSales."Cost Amount";
                                                        POSSales."Consignment Amount (LCY)" := POSSales."Consignment Amount";
                                                    end;

                                                    POSSales."Gross Price" := SalesEntry."Net Price"; //Exclude allowance
                                                    if POSSales.Quantity <> 0 then begin
                                                        POSSales."Disc. Amount From Std. Price" := round(POSSales."Discount Amount" / POSSales.Quantity); //20210104 //Exclude allowance
                                                                                                                                                          //POSSales."Net Price Incl Tax" := SalesEntry.Price - SalesEntry."Discount Amount" / POSSales.Quantity; //20210104
                                                        POSSales."Net Price Incl Tax" := -(SalesEntry."Net Amount" + SalesEntry."VAT Amount") / POSSales.Quantity; //Exclude allowance
                                                    end;

                                                    if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                                                        POSSales."VAT per unit" := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);

                                                    //POSSales."Total Incl Tax" := -(POSSales."Net Price Incl Tax" * SalesEntry.Quantity);
                                                    POSSales."Total Incl Tax" := -(POSSales."Net Price Incl Tax" * SalesEntry.Quantity); //Exclude allowance
                                                    possales."Total Excl Tax" := -SalesEntry."Net Amount"; //UAT-025 :No8.RGV_Payment Notice //Exclude allowance

                                                    if (SalesEntry."VAT Amount" <> 0) and (SalesEntry.Quantity <> 0) then
                                                        POSSales.Tax := -(SalesEntry."VAT Amount" / SalesEntry.Quantity);

                                                    POSSales."Total Tax Collected" := SalesEntry."VAT Amount";
                                                    if POSSales.Quantity <> 0 then
                                                        POSSales."Net Price Excl Tax" := POSSales."Total Excl Tax" / POSSales.Quantity; //20201224

                                                    POSSales.Cost := POSSales."Net Amount" - POSSales."Consignment Amount"; ///Consign Cost
                                                    POSSales."Cost Incl Tax" := POSSales.Cost + ((POSSales.Cost * POSVAT."VAT %") / 100); //UAT-025:Cost Inc Tax :=No9+No.11
                                                    getMDR(SalesEntry, possales."MDR Rate", possales."MDR Weight", possales."MDR Amount");//eddy
                                                    POSSales."MDR Rate Pctg" := possales."MDR Rate" * 100;
                                                    POSSales."Contract ID" := MGPSetup."Contract ID";
                                                    POSSales."Billing Period ID" := MGPSetup."Billing Period ID";
                                                    POSSales."Expected Gross Profit" := MGPSetup."Expected Gross Profit";
                                                    POSSales.insert;
                                                    nextlineno += 100;
                                                end;

                                            end;

                                        until MGPSetup.Next() = 0;
                                    End;
                                End;
                            until (ConsignRate.next = 0);
                        end;

                    until SalesEntry.Next() = 0;
                end;
            until recitem.next = 0;
            if GuiAllowed then gdiag.Close();
        end;
    end;

    procedure GenerateBIDocs()
    var
        ConsignmentBillingPeriod: Record "WP B.Inc Billing Periods";
        Vendor: Record Vendor;
        RetailSetup: Record "LSC Retail Setup";
        dtAssignMonth, dtAssignMonthEnd : Date;
        dtFromDate, dtToDate : Date;
        intrecalFormula: Integer;
    begin
        CLEAR(ConsignmentBillingPeriod);
        /*ConsignmentBillingPeriod.setrange("Batch is done", false);
        ConsignmentBillingPeriod.setrange("Consignment Billing Type", ConsignmentBillingPeriod."Consignment Billing Type"::"Buying Income");
        if ConsignmentBillingPeriod.FindFirst then begin
            REPEAT
                if (ConsignmentBillingPeriod."Billing Cut-off Date" <= Today) then begin
                    CreateSalesInvoices(ConsignmentBillingPeriod);
                    ConsignmentBillingPeriod."Batch Is Done" := true;
                    ConsignmentBillingPeriod."Batch Timestamp" := CurrentDateTime;
                    ConsignmentBillingPeriod.modify(true);
                end;
            until ConsignmentBillingPeriod.Next() = 0;
        end;
        */
        //  intrecalFormula := RetailSetup."Consign. Calc. Daily";
        dtAssignMonth := CALCDATE('-1M', DMY2Date(1, Date2DMY(Today, 2), Date2DMY(Today, 3)));
        dtAssignMonthEnd := CALCDATE('1M-1D', dtAssignMonth); // To day =1/9/2025
        CreateSalesInvoices(dtAssignMonth, dtAssignMonthEnd);
    end;

    procedure CreateBillingEntries(DocNo: code[20];
            pContract: code[20];
            pBillingID: code[20])
    var
        CE: Record "Consignment Entries";
        BE: Record "Consignment Billing Entries";
        BE2: Record "Consignment Billing entries";
        nextlineno: Integer;
    begin
        clear(be);
        be.setrange("Document No.", DocNo);
        be.SetRange("Contract ID", pContract);
        be.SetRange("Billing Period ID", pBillingID);
        be.DeleteAll();

        clear(ce);
        ce.setrange("Document No.", docno);
        ce.SetRange("Contract ID", pContract);
        ce.SetRange("Billing Period ID", pBillingID);
        if ce.FindSet() then begin
            repeat
                cleaR(be);
                be.setrange("Document No.", docno);
                be.setrange("Store No.", ce."Store No.");
                be.SetRange("Vendor No.", ce."Vendor No.");
                be.Setrange("Product Group", ce."Product Group");
                be.setrange("Special Group", ce."Special Group");
                be.setrange("Special Group 2", ce."Special Group 2");
                be.setrange("Consignment %", ce."Consignment %");
                be.setrange("VAT Code", ce."VAT Code");
                be.setrange("Sales Date", ce.Date);
                if not be.FindFirst() then begin
                    //do insert
                    clear(be2);
                    be2.setrange("Document No.", DocNo);
                    if be2.FindLast() then
                        nextlineno := be2."Line No." + 100
                    else
                        nextlineno := 100;

                    be."Document No." := docno;
                    be."Line No." := nextlineno;
                    be."Billing Type" := be."Billing Type"::Sales;
                    be."Store No." := ce."Store No.";
                    be."Vendor No." := ce."Vendor No.";
                    be."Product Group" := ce."Product Group";
                    be."Special Group" := ce."Special Group";
                    be."Special Group 2" := ce."Special Group 2";
                    be."Consignment %" := ce."Consignment %";
                    be."VAT Code" := ce."VAT Code";
                    be."VAT Prod. Posting Group" := ce."VAT Prod. Posting Group";
                    be."Total Incl Tax" := ce."Total Incl Tax";
                    be."Total Excl Tax" := ce."Total Excl Tax";
                    be."Total Tax" := be."Total Incl Tax" - be."Total Excl Tax";
                    be."Cost Incl Tax" := ce."Cost Incl Tax";//UAT-025



                    be.Profit := round(be."Total Excl Tax" * (be."Consignment %" * 0.01));
                    be.Cost := round(be."Total Excl Tax" - be.Profit);
                    be."Product Group Description" := ce."Product Group Description";
                    be."MDR Amount" := ce."MDR Amount";
                    be."MDR Rate" := ce."MDR Rate";
                    be."MDR Weight" := ce."MDR Weight";
                    be."Sales Date" := ce.Date;
                    be.Quantity := ce.Quantity;
                    be."Contract ID" := ce."Contract ID";
                    be."Billing Period ID" := ce."Billing Period ID";
                    be."Expected Gross Profit" := ce."Expected Gross Profit";
                    be.insert(true);
                    ce."Applied to Billing Line No." := nextlineno;
                    ce.modify;
                end else begin
                    //do modify
                    be."Total Excl Tax" += ce."Total Excl Tax";
                    be."Total Incl Tax" += ce."Total Incl Tax";
                    be."Total Tax" := be."Total Incl Tax" - be."Total Excl Tax";
                    be."Cost Incl Tax" += ce."Cost Incl Tax"; //uat-025
                    be.Profit := Round(be."Total Excl Tax" * (be."Consignment %" * 0.01));
                    be.Cost := Round(be."Total Excl Tax" - be.Profit);
                    be."MDR Amount" += ce."MDR Amount";
                    be.Quantity += ce.Quantity;
                    be."Contract ID" := ce."Contract ID";
                    be."Billing Period ID" := ce."Billing Period ID";
                    be."Expected Gross Profit" := ce."Expected Gross Profit";
                    be.modify(true);
                    ce."Applied to Billing Line No." := be."Line No.";
                    ce.modify;
                end;

            until ce.next = 0;
        end;
    end;

    procedure CreateInvoices2(ce: Record "Consignment Entries"; ch: record "Consignment Header")
    var
        LRecCP: Record "Consignment Process Log";
        NextEntryNo: Integer;
        NextLineNo: Integer;
        PINo: code[20];
        SINo: code[20];
        LRecPH: record "Purchase Header";
        LRecPL: record "Purchase Line";
        LRecSH: record "Sales Header";
        LRecSL: record "Sales Line";
        LRecVen: Record Vendor;
        PRel: codeunit "Release Purchase Document";
        SRel: Codeunit "Release Sales Document";
        IsDuplicate: Boolean;
        TempDocNo: Integer;
        i: integer;
        LogVendorNo: code[20];
        LogCustomerNo: code[20];
        MonthText: Text[3];
        InvertedComma: char;
        BE: record "Consignment Billing Entries";
        recStore: Record "LSC Store";
        linefilter: text[250];
    begin
        ce.CalcFields("Special Group Description", "Special Group 2 Description");
        if RetailSetup.Get() then;
        RetailSetup.TestField("Def. Purch. Inv. G/L Acc.");
        RetailSetup.TestField("Def. Sales Inv. G/L Acc.");

        clear(LRecPH);
        lrecph."Document Type" := lrecph."document type"::Invoice;
        lrecph.validate("buy-from vendor no.", ch."vendor no.");
        lrecph."Document Date" := today;
        //lrecph."Posting Date" := CalcDate('CM', today); //20240124-+
        LRecPH."Posting Date" := ch."End Date"; //20240124-+
        LRECPH."Your Reference" := 'CONSIGN';
        lrecph."Consign. Document No." := ch."Document No.";
        Clear(MonthText);
        case Format(LRecPH."Posting Date", 0, '<Month,2>') of
            '01':
                MonthText := 'JAN';
            '02':
                MonthText := 'FEB';
            '03':
                MonthText := 'MAR';
            '04':
                MonthText := 'APR';
            '05':
                MonthText := 'MAY';
            '06':
                MonthText := 'JUN';
            '07':
                MonthText := 'JUL';
            '08':
                MonthText := 'AUG';
            '09':
                MonthText := 'SEP';
            '10':
                MonthText := 'OCT';
            '11':
                MonthText := 'NOV';
            '12':
                MonthText := 'DEC';
        end;
        InvertedComma := 39;

        if lrecph.insert(True) then begin
            pino := lrecph."No.";
            lrecph.validate("Document Date");
            LRecPH.Validate("Posting Date");
            LRecPH."Posting Description" := 'CONSIGN SALES ' + MonthText + InvertedComma + Format(LRecPH."Posting Date", 0, '<Year,2>');
            //20240124-
            if RetailSetup."Def. Shortcut Dim. 1 - Purch" <> '' then
                LRecPH.Validate("Shortcut Dimension 1 Code", RetailSetup."Def. Shortcut Dim. 1 - Purch");
            //20240124+
            LRecPH."Vendor Invoice No." := ch."Document No."; //20240614-+
            LRecPH.Modify();

            CLEAR(BE);
            be.setrange("document no.", ch."Document No.");
            be.setrange("Vendor No.", ch."Vendor No.");
            be.setrange("Contract ID", ch."Contract ID");
            if be.FindSet() then begin
                //be.CalcFields("VAT Code");
                be.SetAutoCalcFields("Product Group Description", "Special Group Description");
                repeat
                    clear(linefilter);
                    linefilter := format(be."Product Group") + '-' + format(be."Product Group Description");
                    clear(LRecPL);
                    lrecpl."Document Type" := lrecpl."Document Type"::Invoice;
                    lrecpl.validate("Document No.", PINo);
                    lrecpl."Line No." := be."Line No." + 100;
                    lrecpl.Type := lrecpl.Type::"G/L Account";
                    lrecpl.validate("No.", RetailSetup."Def. Purch. Inv. G/L Acc.");
                    lrecpl.validate("Location Code", be."Store No.");
                    lrecpl.Validate("Gen. Bus. Posting Group", 'LOCAL');
                    lrecpl.Validate("Gen. Prod. Posting Group", 'RETAIL');
                    //LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_IN');
                    lrecpl.Validate("VAT Prod. Posting Group", be."VAT Prod. Posting Group");
                    lrecpl.validate(Quantity, 1);
                    //lrecpl.validate("Direct Unit Cost", be.Profit);
                    //LRecPL.Validate("Direct Unit Cost", be."Total Excl Tax");
                    //lrecpl.Validate("Unit Cost", be."Total Excl Tax");
                    LRecPL.Validate("Direct Unit Cost", be.Cost);
                    lrecpl.Validate("Unit Cost", be.cost);
                    //lrecpl.Description := be."Product Group Description" + ' ' + format(be."Consignment %") + '%';
                    //lrecpl.Description := be."Special Group Description" + '-' + be."Product Group Description" + '-' + format(be."Consignment %") + '%';
                    lrecpl.Description := linefilter;

                    recStore.Reset();
                    recStore.SetCurrentKey("Location Code");
                    recStore.SetRange("Location Code", LRecPL."Location Code");
                    if recStore.FindFirst() then
                        LRecPL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                    else
                        lrecpl.Validate("Shortcut Dimension 1 Code", LRecPH."Shortcut Dimension 1 Code"); //20240123-+
                    lrecpl.insert(true);

                /*   clear(LRecPL);
                  lrecpl.setrange("Document Type", lrecpl."Document Type"::Invoice);
                  lrecpl.setrange("Document No.", PINo);
                  lrecpl.setrange(Description, linefilter);
                  lrecpl.setrange("Location Code", be."Store No.");
                  lrecpl.setrange(Type, lrecpl.type::"G/L Account");
                  if lrecpl.findfirst then begin
                      //lrecpl."Direct Unit Cost" += be."Total Excl Tax";
                      lrecpl."Direct Unit Cost" += be.Cost;
                      LRecPL.Validate("Direct Unit Cost");
                      //lrecpl."Unit Cost" += be."Total Excl Tax";
                      lrecpl."Unit Cost" += be.Cost;
                      lrecpl.Validate("Unit Cost", be."Total Excl Tax");
                      lrecpl.Modify();
                  end else begin
                      clear(LRecPL);
                      lrecpl."Document Type" := lrecpl."Document Type"::Invoice;
                      lrecpl.validate("Document No.", PINo);
                      lrecpl."Line No." := be."Line No.";
                      lrecpl.Type := lrecpl.Type::"G/L Account";
                      lrecpl.validate("No.", RetailSetup."Def. Purch. Inv. G/L Acc.");
                      lrecpl.validate("Location Code", be."Store No.");
                      //lrecpl.validate("Shortcut Dimension 1 Code", //temppl."Shortcut Dimension 1 Code");                    
                      lrecpl.validate(Quantity, 1);
                      //lrecpl.validate("Direct Unit Cost", be.Profit);
                      //LRecPL.Validate("Direct Unit Cost", be."Total Excl Tax");
                      //lrecpl.Validate("Unit Cost", be."Total Excl Tax");
                      LRecPL.Validate("Direct Unit Cost", be.Cost);
                      lrecpl.Validate("Unit Cost", be.cost);
                      //lrecpl.Description := be."Product Group Description" + ' ' + format(be."Consignment %") + '%';
                      //lrecpl.Description := be."Special Group Description" + '-' + be."Product Group Description" + '-' + format(be."Consignment %") + '%';
                      lrecpl.Description := linefilter;

                      recStore.Reset();
                      recStore.SetCurrentKey("Location Code");
                      recStore.SetRange("Location Code", LRecPL."Location Code");
                      if recStore.FindFirst() then
                          LRecPL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                      else
                          lrecpl.Validate("Shortcut Dimension 1 Code", LRecPH."Shortcut Dimension 1 Code"); //20240123-+
                      lrecpl.insert(true);
                  end; */


                until be.next = 0;
            end;
        end;


        // clear(LRecVen);
        // lrecven.setrange("no.", ch."Vendor No.");
        // if LRecVen.FindFirst() then begin
        //     lrecven.TestField("Linked Customer No.");
        //     clear(LRecsH);
        //     lrecsh."Document Type" := lrecsh."Document Type"::Invoice;
        //     lrecsh.Validate("Sell-to Customer No.", LRecVen."Linked Customer No.");
        //     lrecsh."Document Date" := today;
        //     //lrecsh."Posting Date" := calcdate('CM', Today); //20240124-+
        //     LRecSH."Posting Date" := ch."End Date"; //20240124-+
        //     lrecsh."Your Reference" := 'CONSIGN';
        //     lrecsh."Consign. Document No." := ch."Document No.";
        //     LRecSH."External Document No." := ch."Document No."; //20240124-+
        //     lrecsh.Invoice := true;
        //     if lrecsh.insert(True) then begin
        //         SINo := lrecsh."No.";
        //         lrecSh.validate("Document Date");
        //         LRecSH.Validate("Posting Date");
        //         //20240124-
        //         if RetailSetup."Def. Shortcut Dim. 1 - Sales" <> '' then
        //             LRecSH.Validate("Shortcut Dimension 1 Code", RetailSetup."Def. Shortcut Dim. 1 - Sales");
        //         //20240124+
        //         LRecSH.Modify();
        //         clear(BE);

        //         be.setrange("Document No.", ch."Document No.");
        //         if be.FindSet() then begin
        //             be.SetAutoCalcFields("Product Group Description", "Special Group Description");
        //             repeat
        //                 clear(LRecsL);
        //                 lrecsl."Document Type" := lrecsl."document type"::Invoice;
        //                 lrecsl.validate("Document No.", SINo);
        //                 lrecsl."Line No." := be."line no.";
        //                 lrecsl.Type := lrecsl.Type::"G/L Account";
        //                 lrecsl.validate("No.", RetailSetup."Def. Sales Inv. G/L Acc.");
        //                 lrecsl.validate("Location Code", be."store no.");
        //                 //    lrecsl.validate("Shortcut Dimension 1 Code", tempsl."Shortcut Dimension 1 Code");
        //                 lrecsl.validate(Quantity, 1);
        //                 lrecsl.validate("Unit Price", be.Profit);
        //                 //lrecsl.Description := be."Product Group Description" + ' ' + format(be."Consignment %") + '%';
        //                 lrecsl.Description := be."Special Group Description" + '-' + be."Product Group Description" + '-' + format(be."Consignment %") + '%';

        //                 recStore.Reset();
        //                 recStore.SetCurrentKey("Location Code");
        //                 recStore.SetRange("Location Code", LRecSL."Location Code");
        //                 if recStore.FindFirst() then
        //                     LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
        //                 else
        //                     LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
        //                 lrecsl.insert(true);
        //             until be.next = 0;
        //         end;
        //     end;
        // end;
        //Remove auto post Purchase Invoice
        /*if (pino <> '') then begin
            ch."Purchase Invoice No." := pino;
            //ch."Sales Invoice No." := sino;
            ch.modify;
            RetailSetup.Get(); //IST-00007-          

            if RetailSetup."Auto Post - PI" then begin
                clear(LRecPH);
                LRecPH.setrange("Document Type", lrecsh."Document Type"::Invoice);
                LRecPH.setrange("No.", PINo);
                if LRecPH.findfirst then
                    codeunit.run(90, LRecPH);
            end;
            //IST-00007+
        end;*/
        //END Remove auto post Purchase Invoice
    end;
    //WP Counter Area
    procedure CreateSIManagementFee(BP: record "WP Counter Area")
    var
        LRecCP: Record "Consignment Process Log";
        NextEntryNo: Integer;
        NextLineNo: Integer;
        SINo: code[20];
        LRecSH: record "Sales Header";
        LRecSL: record "Sales Line";
        LRecVen: Record Vendor;
        SRel: Codeunit "Release Sales Document";
        IsDuplicate: Boolean;
        TempDocNo: Integer;
        i: integer;
        LogVendorNo: code[20];
        LogCustomerNo: code[20];
        BE: record "Consignment Billing Entries";
        recStore: Record "LSC Store";
        linefilter: text[250];
        MPGSetup: record "WP MPG Setup";
        ContractDoc: Record "WP Consignment Contracts";
        ConsignEntries: record "Consignment Header";
        MPGAmt: Decimal;
        ConsignAmt: decimal;
        MDRAmt: decimal;
        BillableMPGAmt: decimal;
        MonthText: Text[3];
        InvertedComma: char;
    begin
        if RetailSetup.Get() then;
        RetailSetup.TestField("Def. Sales Inv. G/L Acc.");
        /* clear(LRecVen);
        LRecVen.Reset();
        lrecven.setrange("Is Consignment Vendor", true);
        LRecVen.SetFilter("Consign. Start Date", '<=%1', TODAY);
        LRecVen.SetFilter("Consign. End Date", '>=%1', TODAY);
        LRecVen.SetFilter("No.", '=%1', '100005');
        if lrecven.FindSet(true) then begin
            repeat

            until LRecVen.Next = 0;
        end; */

        bp.Reset();
        // bp.SetRange("Vendor No.", LRecVen."No.");
        bp.SetFilter("Contract ID", '<>%1', '');
        bp.SetFilter("Amount", '<>%1', 0);
        bp.SetFilter("Vendor No.", '<>%1', '');
        bp.SetFilter("Start Date", '<=%1', TODAY);
        bp.SetFilter("End Date", '>=%1', TODAY);

        if bp.FindSet(true) then begin
            repeat

                LRecVen.Get(bp."Vendor No.");
                if (LRecVen."Is Consignment Vendor")
                then begin

                    ContractDoc.Get(bp."Contract ID");
                    if (ContractDoc."Start Date" <= Today) AND (ContractDoc."End Date" >= Today) then begin
                        lrecven.TestField("Linked Customer No.");
                        clear(LRecsH);
                        Clear(MonthText);
                        case Format(lrecsh."Posting Date", 0, '<Month,2>') of
                            '01':
                                MonthText := 'JAN';
                            '02':
                                MonthText := 'FEB';
                            '03':
                                MonthText := 'MAR';
                            '04':
                                MonthText := 'APR';
                            '05':
                                MonthText := 'MAY';
                            '06':
                                MonthText := 'JUN';
                            '07':
                                MonthText := 'JUL';
                            '08':
                                MonthText := 'AUG';
                            '09':
                                MonthText := 'SEP';
                            '10':
                                MonthText := 'OCT';
                            '11':
                                MonthText := 'NOV';
                            '12':
                                MonthText := 'DEC';
                        end;
                        InvertedComma := 39;
                        lrecsh."Document Type" := lrecsh."Document Type"::Invoice;
                        lrecsh.Validate("Sell-to Customer No.", LRecVen."Linked Customer No.");
                        lrecsh."Document Date" := today;
                        // LRecSH."Posting Date" := CalcDate('CM', today) + 3;
                        LRecSH."Posting Date" := today + 5;
                        LRecSH."Posting Description" := 'Phí thu ' + MonthText + InvertedComma + Format(CalcDate('CM', today), 0, '<Year,2>');
                        lrecsh."Your Reference" := 'CONSIGN';
                        lrecsh.Invoice := true;
                        if lrecsh.insert(True) then begin
                            SINo := lrecsh."No.";
                            lrecSh.validate("Document Date");
                            LRecSH.Validate("Posting Date");
                            if RetailSetup."Def. Shortcut Dim. 1 - Sales" <> '' then
                                LRecSH.Validate("Shortcut Dimension 1 Code", RetailSetup."Def. Shortcut Dim. 1 - Sales");
                            LRecSH.Modify();
                            ContractDoc.Get(bp."Contract ID");
                            if bp.Amount <> 0 then begin
                                clear(LRecSL);
                                LRecSL."Document Type" := LRecSL."Document Type"::Invoice;
                                LRecSL.Validate("Document No.", SINo);
                                LRecSL."Line No." := 100;
                                lrecsl.Description := 'Diện tích : ' + format(bp."Area");
                                lrecsl.insert;

                                LRecSL."Line No." := 200;
                                lrecsl.Description := 'Số tiền : ' + format(bp.Amount);
                                lrecsl.insert;

                                LRecSL."Line No." := 1000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51182');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Area");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_Area");
                                lrecsl.validate(Quantity, bp.Quantity_Area);
                                lrecsl.validate("Unit Price", bp.Amount);
                                lrecsl.Description := 'Phí quản lý tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Fixture <> 0 then begin
                                LRecSL."Line No." := 2000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51183');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Fixture");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_Fixture");
                                lrecsl.validate(Quantity, bp.Quantity_Fixture);
                                lrecsl.validate("Unit Price", bp.Fixture);
                                lrecsl.Description := 'Phí hỗ trợ quầy kệ tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Parking <> 0 then begin
                                LRecSL."Line No." := 3000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51184');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Parking");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_Parking");
                                lrecsl.validate(Quantity, bp.Quantity_Parking);
                                lrecsl.validate("Unit Price", bp.Parking);
                                lrecsl.Description := 'Phí đậu xe tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Promotion <> 0 then begin
                                LRecSL."Line No." := 4000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51187');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Promotion");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_Promotion");
                                lrecsl.validate(Quantity, bp.Quantity_Promotion);
                                lrecsl.validate("Unit Price", bp.Promotion);
                                lrecsl.Description := 'Phí khuyến mãi và quảng cáo tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Storage1 <> 0 then begin
                                LRecSL."Line No." := 5000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51183');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_ST1");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_ST1");
                                lrecsl.validate(Quantity, bp.Quantity_ST1);
                                lrecsl.validate("Unit Price", bp.Storage1);
                                lrecsl.Description := 'Phí lưu kho tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Storage2 <> 0 then begin
                                LRecSL."Line No." := 6000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51183');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_ST2");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_ST2");
                                lrecsl.validate(Quantity, bp.Quantity_ST2);
                                lrecsl.validate("Unit Price", bp.Storage2);
                                lrecsl.Description := 'Phí lưu kho tủ lớn tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            if bp.Storage3 <> 0 then begin
                                LRecSL."Line No." := 7000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51183');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_ST3");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_ST3");
                                lrecsl.validate(Quantity, bp.Quantity_ST3);
                                lrecsl.validate("Unit Price", bp.Storage3);
                                lrecsl.Description := 'Phí lưu kho tủ nhỏ tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;

                            IF bp.Storage4 <> 0 then begin
                                LRecSL."Line No." := 9000;
                                lrecsl.Type := lrecsl.Type::"G/L Account";
                                lrecsl.validate("No.", '51183');
                                lrecsl.validate("Location Code", bp."Store No.");
                                LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                                LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                                LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                                LRecSL."Description 2" := ContractDoc.Description;
                                LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_ST4");
                                LRecSL.Validate("Unit of Measure Code", bp."UOM_ST4");
                                lrecsl.validate(Quantity, bp.Quantity_ST4);
                                lrecsl.validate("Unit Price", bp.Storage4);
                                lrecsl.Description := 'Phí lưu kho tủ đông tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                                recStore.Reset();
                                recStore.SetCurrentKey("Location Code");
                                recStore.SetRange("Location Code", LRecSL."Location Code");
                                if recStore.FindFirst() then
                                    LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                                else
                                    LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                                lrecsl.insert(true);
                            end;
                        end;

                        if bp.Storage5 <> 0 then begin
                            LRecSL."Line No." := 10000;
                            lrecsl.Type := lrecsl.Type::"G/L Account";
                            lrecsl.validate("No.", '51183');
                            lrecsl.validate("Location Code", bp."Store No.");
                            LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                            LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                            LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                            LRecSL."Description 2" := ContractDoc.Description;
                            LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_ST5");
                            LRecSL.Validate("Unit of Measure Code", bp."UOM_ST5");
                            lrecsl.validate(Quantity, bp.Quantity_ST5);
                            lrecsl.validate("Unit Price", bp.Storage5);
                            lrecsl.Description := 'Phí lưu kho tháng... ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                            recStore.Reset();
                            recStore.SetCurrentKey("Location Code");
                            recStore.SetRange("Location Code", LRecSL."Location Code");
                            if recStore.FindFirst() then
                                LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                            else
                                LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                            lrecsl.insert(true);
                        end;

                        if bp.Locker <> 0 then begin
                            LRecSL."Line No." := 11000;
                            lrecsl.Type := lrecsl.Type::"G/L Account";
                            lrecsl.validate("No.", '51183');
                            lrecsl.validate("Location Code", bp."Store No.");
                            LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                            LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                            LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                            LRecSL."Description 2" := ContractDoc.Description;
                            LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Locker");
                            LRecSL.Validate("Unit of Measure Code", bp."UOM_Locker");
                            lrecsl.validate(Quantity, bp.Quantity_Locker);
                            lrecsl.validate("Unit Price", bp.Locker);
                            lrecsl.Description := 'Phí quản lý tủ khóa nhân viên tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                            recStore.Reset();
                            recStore.SetCurrentKey("Location Code");
                            recStore.SetRange("Location Code", LRecSL."Location Code");
                            if recStore.FindFirst() then
                                LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                            else
                                LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                            lrecsl.insert(true);
                        end;

                        if bp.Locker1 <> 0 then begin
                            LRecSL."Line No." := 12000;
                            lrecsl.Type := lrecsl.Type::"G/L Account";
                            lrecsl.validate("No.", '51183');
                            lrecsl.validate("Location Code", bp."Store No.");
                            LRecSL.Validate("Gen. Bus. Posting Group", 'LOCAL');
                            LRecSL.Validate("Gen. Prod. Posting Group", 'RETAIL');
                            LRecSL.Validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                            LRecSL."Description 2" := ContractDoc.Description;
                            LRecSL.Validate("VAT Prod. Posting Group", bp."VAT_Locker1");
                            LRecSL.Validate("Unit of Measure Code", bp."UOM_Locker1");
                            lrecsl.validate(Quantity, bp.Quantity_Locker1);
                            lrecsl.validate("Unit Price", bp.Locker1);
                            lrecsl.Description := 'Phí tủ khóa lớn tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3))) + '-';
                            recStore.Reset();
                            recStore.SetCurrentKey("Location Code");
                            recStore.SetRange("Location Code", LRecSL."Location Code");
                            if recStore.FindFirst() then
                                LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                            else
                                LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                            lrecsl.insert(true);
                        end;
                    end;
                end;
            until bp.Next() = 0;
        end;
    end;
    //end
    procedure CreateSalesInvoices(salesDate: Date; endSalesDate: date)
    var
        LRecCP: Record "Consignment Process Log";
        NextEntryNo: Integer;
        NextLineNo: Integer;
        SINo: code[20];
        LRecSH: record "Sales Header";
        LRecSL: record "Sales Line";
        LRecSHMDR: record "Sales Header";
        LRecSLMDR: record "Sales Line";
        LRecVen: Record Vendor;
        SRel: Codeunit "Release Sales Document";
        IsDuplicate: Boolean;
        TempDocNo: Integer;
        i: integer;
        LogVendorNo: code[20];
        LogCustomerNo: code[20];
        BE: record "Consignment Billing Entries";
        recStore: Record "LSC Store";
        linefilter: text[250];
        MPGSetup: record "WP MPG Setup";
        ConsignEntries: record "Consignment Header";
        MPGAmt: Decimal;
        ConsignAmt: decimal;
        MDRAmt: decimal;
        TotalMDRAmt: Decimal;
        BillableMPGAmt: decimal;
        MonthText: Text[3];
        InvertedComma: char;
        TempConsignEntries: Record "Consignment Header" temporary;
        BillingTotalProfit: Decimal;
        ExpectedGrossProfit: Decimal;

    begin
        clear(ConsignAmt);
        clear(MPGAmt);
        clear(MDRAmt);
        clear(ConsignEntries);
        Clear(TempConsignEntries);
        ConsignEntries.Reset();
        ConsignEntries.SetCurrentKey("Vendor No.", "Start Date");
        ConsignEntries.setrange(Status, ConsignEntries.Status::"Posted");
        ConsignEntries.setrange("Start Date", salesDate, endSalesDate);
        ConsignEntries.SetFilter("Expected Gross Profit", '<>0');
        if ConsignEntries.FindSet() then begin
            repeat
                if (ConsignEntries."Start Date" >= salesDate) and (ConsignEntries."End Date" <= endSalesDate) then begin
                    //  ConsignEntries.CalcFields("Billing - Total Profit", "Total MDR Amount");
                    //  ConsignAmt += ConsignEntries."Billing - Total Profit";
                    //  MDRAmt += ConsignEntries."Total MDR Amount";
                    BillingTotalProfit := 0;
                    TotalMDRAmt := 0;
                    MDRAmt := 0;
                    be.SetRange("Contract ID", ConsignEntries."Contract ID");
                    be.SetRange("Vendor No.", ConsignEntries."Vendor No.");
                    //be.SetRange("Vendor No.", '100005');
                    if be.FindSet() then
                        repeat
                            //Billing total profit
                            BillingTotalProfit += be."Cost";
                            //MDR Amt
                            TotalMDRAmt += be."MDR Amount";
                            //ExpectedGrossProfit
                            if be."Expected Gross Profit" <> 0 then
                                ExpectedGrossProfit := be."Expected Gross Profit";
                        until be.Next() = 0;
                    ConsignAmt := Round(BillingTotalProfit);
                    MDRAmt := Round(TotalMDRAmt);
                    Clear(BillableMPGAmt);
                    BillableMPGAmt := ExpectedGrossProfit - ConsignAmt;
                    lrecsh.Invoice := true;

                    clear(LRecSH);
                    clear(LRecSL);
                    clear(LRecSLmdr);
                    LRecSH."Document Type" := LRecSH."Document Type"::Invoice;
                    LRecSH.Validate("Sell-to Customer No.", be."Vendor No.");
                    LRecSH."Document Date" := today;
                    LRecSH."Posting Date" := today + 5;
                    LRecSH."Your Reference" := 'CONSIGN';
                    LRecSH.Invoice := true;

                    //MGP sales invoice
                    if BillableMPGAmt > 0 then begin
                        clear(LRecSL);
                        clear(LRecSLmdr);
                        if lrecsh.insert(True) then begin

                            //if BillableMPGAmt > 0 then begin
                            SINo := lrecsh."No.";
                            lrecSh.validate("Document Date");
                            LRecSH.Validate("Posting Date");
                            if RetailSetup."Def. Shortcut Dim. 1 - Sales" <> '' then
                                LRecSH.Validate("Shortcut Dimension 1 Code", RetailSetup."Def. Shortcut Dim. 1 - Sales");
                            LRecSH.Modify();


                            LRecSL."Document Type" := LRecSL."Document Type"::Invoice;
                            LRecSL.Validate("Document No.", SINo);
                            LRecSL."Line No." := 100;
                            lrecsl.Description := 'Total Profit Amt : ' + format(ConsignAmt);
                            lrecsl.insert;

                            LRecSL."Line No." := 200;
                            lrecsl.Description := 'Min. Prof. Grtee : ' + format(ExpectedGrossProfit);
                            lrecsl.insert;

                            LRecSL."Line No." := 300;
                            lrecsl.Description := 'Billable Amt : ' + format(BillableMPGAmt);
                            lrecsl.insert;

                            LRecSL."Line No." := 400;
                            lrecsl.Description := 'MDR Amt : ' + format(MDRAmt);
                            lrecsl.insert;

                            LRecSL."Line No." := 1000;
                            lrecsl.Type := lrecsl.Type::"G/L Account";
                            lrecsl.validate("No.", '51186');
                            lrecsl.validate("Gen. Bus. Posting Group", 'LOCAL');
                            lrecsl.validate("Gen. Prod. Posting Group", 'RETAIL');
                            lrecsl.validate("Location Code", MPGSetup."Store No.");
                            lrecsl.validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                            lrecsl.validate("VAT Prod. Posting Group", 'VAT_INC_10');
                            lrecsl.validate("Location Code", MPGSetup."Store No.");
                            lrecsl.validate(Quantity, 1);
                            lrecsl.validate("Unit Price", BillableMPGAmt);
                            lrecsl.Description := 'Doanh thu bổ sung tháng ' + Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3)));
                            lrecsl."Description 2" := '';
                            recStore.Reset();
                            recStore.SetCurrentKey("Location Code");
                            recStore.SetRange("Location Code", LRecSL."Location Code");
                            if recStore.FindFirst() then
                                LRecSL.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                            else
                                LRecSL.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                            lrecsl.insert(true);
                        end;
                    end;
                    //MDR fee : sales invoices
                    if ABS(MDRAmt) > 0 then begin
                        if lrecsh.insert(True) then begin

                            // if MDRAmt > 0 then begin
                            SINo := lrecsh."No.";
                            lrecsh.validate("Document Date");
                            lrecsh.Validate("Posting Date");
                            if RetailSetup."Def. Shortcut Dim. 1 - Sales" <> '' then
                                lrecsh.Validate("Shortcut Dimension 1 Code", RetailSetup."Def. Shortcut Dim. 1 - Sales");
                            lrecsh.Modify();

                            clear(LRecSL);
                            clear(LRecSLmdr);
                            LRecSLmdr."Document Type" := LRecSLmdr."Document Type"::Invoice;
                            LRecSLmdr.Validate("Document No.", SINo);
                            LRecSLmdr."Line No." := 100;
                            lrecslmdr.Description := 'Total Con.Amt : ' + format(ConsignAmt);
                            lrecslmdr.insert;

                            LRecSLmdr."Line No." := 200;
                            lrecslmdr.Description := 'Min. Prof. Grtee : ' + format(ExpectedGrossProfit);
                            lrecslmdr.insert;

                            LRecSLmdr."Line No." := 300;
                            lrecslmdr.Description := 'Billable Amt : ' + format(BillableMPGAmt);
                            lrecslmdr.insert;

                            LRecSLmdr."Line No." := 400;
                            lrecslmdr.Description := 'MDR Amt : ' + format(MDRAmt);
                            lrecslmdr.insert;

                            LRecSLmdr."Line No." := 2000;
                            lrecslmdr.Type := lrecslmdr.Type::"G/L Account";
                            lrecslmdr.validate("No.", '51181');
                            lrecslmdr.validate("Gen. Bus. Posting Group", 'LOCAL');
                            lrecslmdr.validate("Gen. Prod. Posting Group", 'RETAIL');
                            lrecslmdr.validate("Location Code", MPGSetup."Store No.");
                            lrecslmdr.validate("VAT Bus. Posting Group", 'DOMESTIC_OUT');
                            lrecslmdr.validate("VAT Prod. Posting Group", 'VAT_INC_10');
                            lrecslmdr.validate(Quantity, 1);
                            lrecslmdr.validate("Unit Price", ABS(MDRAmt));
                            lrecslmdr.Description := 'Phí giao dịch thẻ ';
                            lrecslmdr."Description 2" := Format(FORMAT(DATE2DMY(TODAY, 2)) + '-' + FORMAT(DATE2DMY(TODAY, 3)));
                            recStore.Reset();
                            recStore.SetCurrentKey("Location Code");
                            recStore.SetRange("Location Code", LRecSLmdr."Location Code");
                            if recStore.FindFirst() then
                                LRecSLmdr.Validate("Shortcut Dimension 1 Code", recStore."Global Dimension 1 Code")
                            else
                                LRecSLmdr.Validate("Shortcut Dimension 1 Code", LRecSH."Shortcut Dimension 1 Code"); //20240123-+
                            lrecslmdr.insert(true);
                        end;
                    end;
                end;
            until ConsignEntries.Next() = 0;
        end;
        Clear(TempConsignEntries);


    end;


    procedure getProductGroupDesc(itemNo: code[20]): text[50]
    var
        RetailProductGroup: Record "LSC Retail Product Group";
        Item: Record item;
    begin
        Item.Reset();
        Item.SetLoadFields("LSC Retail Product Code");
        if Item.Get(itemNo) then;

        RetailProductGroup.Reset();
        RetailProductGroup.SetRange("Item Category Code", item."Item Category Code");
        RetailProductGroup.SetRange(Code, item."LSC Retail Product Code");
        RetailProductGroup.SetLoadFields(Description);
        if RetailProductGroup.FindFirst() then
            exit(RetailProductGroup.Description)
        else
            exit(Item."LSC Retail Product Code");
    end;

    procedure marginBlockActive(sdate: date)
    var
        ConsignmentMarginBlock: Record "consignment margin block";
    begin
        ConsignmentMarginBlock.Reset();
        ConsignmentMarginBlock.SetCurrentKey("Start Date", "End Date");
        ConsignmentMarginBlock.SetRange("Start Date", 0D, sdate);
        ConsignmentMarginBlock.setrange("End Date", sdate, 20991231D);
        if ConsignmentMarginBlock.FindFirst() then
            Error(StrSubstNo(txtMarginBlock, format(ConsignmentMarginBlock."Start Date"), format(ConsignmentMarginBlock."End Date")));
    end;

    procedure testSendEmail()
    var
        recconsignentry: record "Consignment Entries";
        reportArchive: Record "Report Inbox";
        tempBlob: Codeunit "Temp Blob";
        pdfOutStream: OutStream;
        pdfInStream: InStream;
        email: Codeunit email;
        emailmessage: Codeunit "Email Message";
        bodyText: text;
    begin
        tempBlob.CreateOutStream(pdfOutStream);
        if recconsignentry.FindFirst() then
            report.SaveAs(70001, '', ReportFormat::Pdf, pdfOutStream);

        tempBlob.CreateInStream(pdfInStream);
        bodyText := 'Good day Sir/Ms,<br></br>I hope this email finds you well. Attached is the monthly POS statement and Tax Invoice for your perusal.<br></br>If you have any inquiries, do not hesitate to contact us.<br></br>Have a good day!<br></br>Regards,<br></br>Isetan of Japan Sdn Bhd';
        //sendEmail('eddy.ong@rgtech.com.my', 'Hi this the test email.', 'Please find the attachment etc etc..', pdfInStream);
        emailmessage.Create('huan.tva@radiantglobal.com.vn; tiang.sj@radiantglobal.com.vn;lam.hn@radiantglobal.com.vn', 'Monthly POS Statement & Tax Invoice', bodyText, true);
        emailmessage.AddAttachment('Invoice.pdf', 'PDF', pdfInStream);
        email.send(emailmessage, enum::"Email Scenario"::Default);
    end;

    procedure ConsignDocSendEmail(CD: Record "Consignment Header"): Boolean;
    var
        recconsignentry: record "Consignment Entries";
        consignmentHeader: Record "Consignment Header";
        reportArchive: Record "Report Inbox";
        tempBlob: Codeunit "Temp Blob";
        pdfOutStream: OutStream;
        pdfInStream: InStream;
        email: Codeunit email;
        emailmessage: Codeunit "Email Message";
        Vendor: Record Vendor;
        psicode: code[20];
        recsih: Record "Sales Invoice Header";
        recRepSel: record "Report Selections";
        repid: integer;
        recref: recordref;
        errorMsg: TextConst ENU = 'Youre not allowed to send e-mail for document status %1. Please post %2 before sending an e-mail.';//001
        emailBodyMsg: Text;
    begin
        if cd.Status < 2 then error(StrSubstNo(errorMsg, format(cd.status), cd."Document No."));

        cd.CalcFields("Posted Sales Invoice No.");
        if cd."Posted Sales Invoice No." = '' then
            exit(False)
        else
            psicode := cd."Posted Sales Invoice No.";

        Clear(emailBodyMsg);
        RetailSetup.Reset();
        if RetailSetup.Get() then
            RetailSetup.TestField("Consign. E-Mail Body Text");
        emailBodyMsg := RetailSetup.GetEmailBodyText();

        Vendor.Reset();
        Vendor.SetRange("No.", cd."Vendor No.");
        Vendor.SetLoadFields("E-Mail");
        if Vendor.FindFirst() then
            Vendor.TestField("E-Mail");

        emailmessage.Create(Vendor."E-Mail", 'Monthly POS Statement & Tax Invoice', emailBodyMsg, true);

        tempBlob.CreateOutStream(pdfOutStream);
        consignmentHeader.Reset();
        consignmentHeader.SetRange("Document No.", cd."Document No.");
        if consignmentHeader.FindFirst() then begin
            Clear(recref);
            recref.open(consignmentHeader.RecordId.TableNo);
            recref.copy(consignmentHeader);
            report.SaveAs(70005, '', ReportFormat::Pdf, pdfOutStream, recref);
            tempBlob.CreateInStream(pdfInStream);
            emailmessage.AddAttachment('Statement.pdf', 'PDF', pdfInStream);
            recref.Close();
        end;

        //print sales invoice report-
        clear(recsih);
        recsih.setrange("No.", psicode);
        if recsih.FindFirst() then begin
            clear(recRepSel);
            clear(tempBlob);
            recRepSel.SetRange(Usage, recRepSel.Usage::"S.Invoice");
            if recrepsel.FindFirst() then begin
                repid := recRepSel."Report ID";
            end;
            clear(recref);
            recref.open(recsih.RecordId.TableNo);
            recref.copy(recsih);
            clear(pdfInStream);
            clear(pdfOutStream);
            tempBlob.CreateOutStream(pdfOutStream);
            report.SaveAs(repid, '', ReportFormat::Pdf, pdfOutStream, recref);
            tempBlob.CreateInStream(pdfInStream);
            recref.Close();
            emailmessage.AddAttachment('Invoice_' + psicode + '.pdf', 'PDF', pdfInStream);
        end;
        //print sales invoice report+
        email.send(emailmessage, enum::"Email Scenario"::Default);
        exit(true);
    end;

    procedure generateConsignDocs()
    var
        ConsignmentBillingPeriod: Record "WP B.Inc Billing Periods";
        ConsignmentHeader: Record "Consignment Header";
        ConsignmentEntries: Record "Consignment Entries";
        Vendor: Record Vendor;
        ConsignmentMarginSetup: Record "WP Consignment Margin Setup";
        MGPSetup: Record "WP MPG Setup";
    begin
        CLEAR(ConsignmentBillingPeriod);
        Clear(ConsignmentMarginSetup);

        ConsignmentBillingPeriod.setrange("Batch is done", false);
        ConsignmentBillingPeriod.setrange("Consignment Billing Type", ConsignmentBillingPeriod."Consignment Billing Type"::"Buying Income");
        if ConsignmentBillingPeriod.FindFirst then begin
            REPEAT

                if (ConsignmentBillingPeriod."Billing Cut-off Date" = Today) then begin
                    Vendor.Reset();
                    Vendor.SetRange("Is Consignment Vendor", true);
                    // Vendor.setrange("Consign. Billing Frequency", ConsignmentBillingPeriod."Period Type");
                    //Vendor.SetLoadFields("Is Consignment Vendor", "Consign. Start Date");
                    if Vendor.FindSet() then begin
                        repeat
                            // if (Vendor."Consign. Start Date" <= ConsignmentBillingPeriod."Start Date") then begin
                            MGPSetup.SetRange("Vendor No.", Vendor."No.");
                            MGPSetup.SetRange("Billing Period ID", ConsignmentBillingPeriod.ID);
                            if MGPSetup.FindSet() then begin
                                repeat
                                    IF MGPSetup."Vendor No." <> '' then begin
                                        //check duplicate documents-
                                        ConsignmentHeader.Reset();
                                        ConsignmentHeader.setrange("Vendor No.", Vendor."No.");
                                        ConsignmentHeader.setrange("Start Date", ConsignmentBillingPeriod."Start Date");
                                        ConsignmentHeader.SetRange("End Date", ConsignmentBillingPeriod."End Date");
                                        ConsignmentHeader.SetLoadFields("Vendor No.", "Start Date", "End Date", Status, "Document Date");
                                        if ConsignmentHeader.FindFirst() then
                                            if (ConsignmentHeader.status = ConsignmentHeader.status::Open) then
                                                ConsignmentHeader.Delete(true);

                                        //check duplicate documents+
                                        //create documents-
                                        ConsignmentHeader.Reset();
                                        ConsignmentHeader.Init();
                                        ConsignmentHeader."Document No." := '';
                                        ConsignmentHeader."Document Date" := ConsignmentBillingPeriod."Billing Cut-off Date";
                                        ConsignmentHeader."Vendor No." := Vendor."No.";
                                        ConsignmentHeader."Start Date" := ConsignmentBillingPeriod."Start Date";
                                        ConsignmentHeader."End Date" := ConsignmentBillingPeriod."End Date";
                                        ConsignmentHeader."Contract ID" := MGPSetup."Contract ID";
                                        ConsignmentHeader."Billing Period ID" := MGPSetup."Billing Period ID";
                                        ConsignmentHeader."Expected Gross Profit" := MGPSetup."Expected Gross Profit";
                                        ConsignmentHeader.Insert(true);

                                        DeleteSalesDateByDocument(ConsignmentHeader."Document No.", MGPSetup."Contract ID");
                                        GetInfo(ConsignmentHeader."Vendor No.", ConsignmentHeader."Start Date", ConsignmentHeader."End Date", '');
                                        CopySalesData2(ConsignmentHeader."Start Date", ConsignmentHeader."End Date", '', ConsignmentHeader."Vendor No.", ConsignmentHeader."Document No.", MGPSetup."Contract ID", MGPSetup."Billing Period ID");
                                        CreateBillingEntries(ConsignmentHeader."Document No.", MGPSetup."Contract ID", MGPSetup."Billing Period ID");

                                        if ConsignmentHeader.Status = ConsignmentHeader.Status::Open then begin
                                            ConsignmentHeader.Status := ConsignmentHeader.Status::Released;
                                            ConsignmentHeader.Modify();
                                        end;
                                        //create documents+
                                    end;
                                until MGPSetup.Next() = 0;

                            end;

                        //end;
                        until Vendor.Next() = 0;


                    end;


                    ConsignmentBillingPeriod."Batch is done" := true;
                    ConsignmentBillingPeriod."Batch Timestamp" := CurrentDateTime;
                    ConsignmentBillingPeriod."Run By USERID" := UserId;
                    ConsignmentBillingPeriod.Modify();
                end;
            UNTIL ConsignmentBillingPeriod.NEXT = 0;
        end;
    end;

    procedure getMDR(TSE: record "LSC Trans. Sales Entry"; var MDRRate: Decimal; var MDRWeight: Decimal; var MDRAmt: Decimal)
    var
        LRecTPE: Record "LSC Trans. Payment Entry";
        LRecTTS: Record "LSC Tender Type Setup";
        LRecTH: Record "LSC Transaction Header";
        TotalPayment: decimal;
        TenderAmount: decimal;
    begin
        clear(MDRRate);
        clear(MDRWeight);
        clear(MDRAmt);
        clear(LRecTPE);
        //key(Key1; "Store No.", "POS Terminal No.", "Transaction No.", "Line No.")
        LRecTPE.setrange("Store No.", TSE."Store No.");
        LRecTPE.setrange("POS Terminal No.", TSE."POS Terminal No.");
        LRecTPE.setrange("Transaction No.", TSE."Transaction No.");
        if lrectpe.FindFirst() then begin
            repeat
                clear(LRecTTS);
                LRecTTS.setrange(lrectts.Code, lrectpe."Tender Type");
                if LRecTTS.FindFirst() then begin
                    if lrectts."Integration MDR Rate" <> 0 then begin
                        MDRRate := LRecTTS."Integration MDR Rate";
                        TenderAmount += lrectpe."Amount Tendered";
                    end;
                end;
            until lrectpe.next = 0;
            if MDRRate <> 0 then begin
                clear(LRecTH);
                LRecTH.setrange("Store No.", tse."Store No.");
                lrecth.setrange("POS Terminal No.", tse."POS Terminal No.");
                LRecTH.setrange("Transaction No.", tse."Transaction No.");
                if lrecth.FindFirst() then begin
                    IF (tse."wp Member Disc. Amount" <> 0) OR (tse."wp Staff Disc. Amount" <> 0) then begin
                        tse."Total Rounded Amt." := tse."Total Rounded Amt." - (tse."wp Member Disc. Amount" + tse."wp Staff Disc. Amount")
                    end;

                    TotalPayment := lrecth.Payment;
                    IF TotalPayment <> 0 then begin
                        MDRWeight := TenderAmount / TotalPayment;
                        MDRAmt := (tse."Total Rounded Amt." * MDRRate) * MDRWeight;
                    end
                    else begin
                        MDRWeight := 0;
                        //MDRAmt := (tse."Net Amount" * MDRRate) * MDRWeight; UAT-0025: Remove  Net Amount
                        MDRAmt := tse."Total Rounded Amt." * MDRRate; //UAT-0025: Change netamt to gross amt
                    end;
                end;
            end;
        end;

    end;



    var
        RetailSetup: Record "LSC Retail Setup";
        VendNo: Code[20];
        StoreNo: Code[10];
        StartDate: Date;
        EndDate: Date;
        i: Integer;
        intCount: Integer;
        txtMarginBlock: TextConst ENU = 'Margin cannot be changed from %1 to %2.';

}
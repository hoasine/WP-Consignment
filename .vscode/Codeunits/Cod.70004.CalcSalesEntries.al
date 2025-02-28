codeunit 70004 "Calculate Sales Entries"
{

    var
        RetailSetup: Record "LSC Retail Setup";
        SchedulerHdr: Record "LSC Scheduler Job Header";
        intdateFormula: Integer;
        txtDateFormula: Text;
        salesDate: Date;
        endSalesDate: Date;
        i: Integer;
        dtassignDate: Date;
        ConsignUtil: Codeunit "Consignment Util";

    trigger OnRun()
    begin
        ClearLastError();
        CalculateSalesEntries();
    end;

    local procedure CalculateSalesEntries()
    var
        dtAssignMonth: Date;
        dtAssignMonthEnd: Date;
    begin
        RetailSetup.Get();
        intdateFormula := RetailSetup."Consign. Calc. Days/Months";
        dtassignDate := Today;

        if RetailSetup."Consignment Calc. Cycle" = RetailSetup."Consignment Calc. Cycle"::Daily then begin
            for i := 1 to intdateFormula do begin
                txtDateFormula := '-' + Format(i) + 'D';
                salesDate := CalcDate(txtDateFormula, dtassignDate);
                CopySalesData(salesDate, salesDate, RetailSetup."Consignment Calc. Cycle");
                MoveConsignmentRateBlank(Format(salesDate, 0, '<Year4><Month,2><Day,2>'));
                Commit();
            end;
        end;

        if RetailSetup."Consignment Calc. Cycle" = RetailSetup."Consignment Calc. Cycle"::Monthly then begin
            if RetailSetup."Consign. Calc. Start Date" <> 0D then
                dtassignDate := RetailSetup."Consign. Calc. Start Date";

            for i := 1 to intdateFormula do begin
                if i = 1 then
                    txtDateFormula := '-CM'
                else
                    txtDateFormula := '-CM-' + Format(i - 1) + 'M';

                salesDate := CalcDate(txtDateFormula, dtassignDate);
                endSalesDate := CalcDate('CM', salesDate);
                CopySalesData(salesDate, endSalesDate, RetailSetup."Consignment Calc. Cycle");
                MoveConsignmentRateBlank(Format(salesDate, 0, '<Year4><Month,2>'));
                Commit();
            end;
        end;
    end;

    procedure CopySalesData(pSalesDate: Date; pSalesDateEnd: Date; pCycle: Enum "Consignment Calc. Cycle")
    var
        TransHeader: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        ConsignHdr: Record "Daily Consignment Checklist";
        POSSales: Record "Daily Consign. Sales Details";
        Missingsales: Record "Daily Consign. Sales Missing";
        Item: Record item;
        ItemSpecialGrp: Record "LSC Item/Special Group Link";
        Barc: Record "LSC barcodes";
        CurrExcRate: Record "Currency Exchange Rate";
        POSVAT: Record "LSC POS VAT Code";
        TransDiscEntry: Record "LSC Trans. Discount Entry";
        cuConsignUtil: Codeunit "Consignment Util";
        discPerc: Decimal;
        ckDiscount: Decimal;
        CostAmountActual: Decimal;
        CostPerUnit: Decimal;
        ConsignGroup: text[250];
        StoreVendor: code[20];
        i: Integer;
        Dialog: Dialog;
        nextLineNo: Integer;
        docNo: Code[20];
    begin
        if pCycle = pCycle::Daily then
            docNo := Format(pSalesDate, 0, '<Year4><Month,2><Day,2>')
        else
            docNo := Format(pSalesDate, 0, '<Year4><Month,2>');

        POSSales.Reset();
        POSSales.SetFilter("Document No.", docNo);
        if not POSSales.IsEmpty then
            POSSales.DeleteAll();

        Missingsales.Reset();
        Missingsales.SetFilter("Document No.", docNo);
        if not Missingsales.IsEmpty then
            Missingsales.DeleteAll();

        ConsignHdr.Reset();
        ConsignHdr.SetRange("Document No.", docNo);
        if not ConsignHdr.FindFirst() then begin
            ConsignHdr."Document No." := docNo;
            ConsignHdr.Insert(true);
        end else
            ConsignHdr.Modify(true);

        i := 0;
        nextLineNo := 1;

        TransHeader.Reset();
        TransHeader.SetCurrentKey("Store No.", Date);
        TransHeader.SetRange(Date, pSalesDate, pSalesDateEnd);
        TransHeader.SetFilter("Entry Status", '0|2');
        TransHeader.SetRange("Transaction Type", TransHeader."Transaction Type"::Sales);
        TransHeader.SetLoadFields(Date, "Transaction Type", "Entry Status", "Posted Statement No.", "Member Card No.", "Trans. Currency", "Posted Statement No.");
        if TransHeader.FindSet() then begin
            if GuiAllowed then begin
                Dialog.Open('Processing Transaction..\Records:#1########## of #2##########\Date: #3##########');
                Dialog.update(2, format(TransHeader.Count));
                if pSalesDateEnd <> pSalesDate then
                    Dialog.Update(3, StrSubstNo('%1..%2', pSalesDate, pSalesDateEnd))
                else
                    Dialog.Update(3, pSalesDate);
            end;
            repeat
                i += 1;
                if GuiAllowed then Dialog.update(1, format(i));

                SalesEntry.Reset();
                SalesEntry.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.", Date, "Gen. Prod. Posting Group");
                SalesEntry.SetRange("Store No.", TransHeader."Store No.");
                SalesEntry.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                SalesEntry.SetRange("Transaction No.", TransHeader."Transaction No.");
                SalesEntry.SetRange(Date, pSalesDate, pSalesDateEnd);
                ConsignGroup := cuConsignUtil.GetConsignPostGroup();
                if ConsignGroup <> '' then SalesEntry.SetFilter("Gen. Prod. Posting Group", ConsignGroup);
                if SalesEntry.FindSet() then
                    repeat

                        POSSales.Reset();
                        POSSales.Init();
                        POSSales."Document No." := docNo;
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
                        // StoreVendor := cuConsignUtil.GetVendorCode(SalesEntry);
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
                        POSSales."Created By" := UserId;
                        POSSales."Created Date" := CurrentDateTime;

                        //CalcConsignment(POSSales."Vendor No.", POSSales.Date, POSSales, POSSales."Consignment Type");
                        POSSales."Consignment %" := CalcConsignPerc(POSSales);
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
                        ConsignUtil.getMDR(SalesEntry, POSSales."MDR Rate", possales."mdr weight", POSSales."MDR Amount");
                        POSSales.Insert();

                        nextLineNo += 1;
                    until SalesEntry.Next() = 0;
            until TransHeader.Next() = 0;
            if GuiAllowed then Dialog.Close();
        end;
    end;

    // procedure CalcConsignment(pVendNo: Code[20]; pDateValid: Date; xpPOSSales: Record "Daily Consign. Sales Details"; var RtnConsignType: Code[20])
    // var
    //     ConsignStp: Record "Consignment Setup";
    //     pPOSSales: Record "Daily Consign. Sales Details" temporary;
    // begin
    //     pPOSSales.Reset();
    //     pPOSSales := xpPOSSales;
    //     pPOSSales.Insert();

    //     Clear(RtnConsignType);

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
    //     if pPOSSales."Total Discount" <> '' then
    //         ConsignStp.SetFilter("Total Discount", pPOSSales."Total Discount")
    //     else
    //         ConsignStp.SetFilter("Total Discount", '');
    //     if ConsignStp.FindSet() then begin
    //         repeat
    //             if ConsignStp."Sub Type" = pPOSSales."Item No." then
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                      and (pPOSSales."Total Discount" = ConsignStp."Total Discount") then //20240513+ 
    //                     RtnConsignType := ConsignStp."Consignment Type";
    //         until (ConsignStp.Next() = 0) or (RtnConsignType <> '');
    //     end;
    //     //20240513-
    //     if RtnConsignType = '' then begin
    //         ConsignStp.setrange("Hierarchy Type", ConsignStp."Hierarchy Type"::"Special Group 2");
    //         if ConsignStp.FindSet() then begin
    //             repeat
    //                 if (pPOSSales."Promotion No." = ConsignStp."Promotion No.") and (pPOSSales."Periodic Offer No." = ConsignStp."Periodic Discount Offer")
    //                 and (pPOSSales."Total Discount" = ConsignStp."Total Discount")//20240513+ 
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

    local procedure CalcConsignPerc(pPosSales: Record "Daily Consign. Sales Details"): Decimal
    var
        ConsignRate: Record "WP Consignment Margin Setup";
        //recRate: Record "Consignment Rate";
        intConsignRate: Decimal;
    begin
        Clear(intConsignRate);
        //withStoreCode
        ConsignRate.Reset();
        ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
        ConsignRate.SetRange("Start Date", 0D, pPosSales.Date);
        ConsignRate.SetFilter("End Date", '>=%1|%2', pPosSales.Date, 0D);
        ConsignRate.setrange("Item No.", pPosSales."Item No.");
        //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");        
        ConsignRate.SetRange("Store No.", pPosSales."Store No.");
        if ConsignRate.FindLast() then
            intConsignRate := ConsignRate."Profit Margin";

        //WithoutStoreCode
        if intConsignRate = 0 then begin
            ConsignRate.Reset();
            ConsignRate.SetRange("Vendor No.", pPosSales."Vendor No.");
            ConsignRate.SetRange("Start Date", 0D, pPosSales.Date);
            ConsignRate.SetFilter("End Date", '>=%1|%2', pPosSales.Date, 0D);
            ConsignRate.setrange("Item No.", pPosSales."Item No.");
            //ConsignRate.SetRange("Consignment Type", pPosSales."Consignment Type");
            ConsignRate.SetFilter("Store No.", '');
            if ConsignRate.FindLast() then begin
                if ConsignRate."Store No." = '' then
                    intConsignRate := ConsignRate."Profit Margin";
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

    local procedure MoveConsignmentRateBlank(pSalesDate: Text)
    var
        ConsignSalesMissing: Record "Daily Consign. Sales Missing";
        ConsignSalesDetails: Record "Daily Consign. Sales Details";
    begin
        ConsignSalesDetails.Reset();
        ConsignSalesDetails.SetRange("Document No.", pSalesDate);
        ConsignSalesDetails.SetFilter("Consignment Type", '''''');
        if ConsignSalesDetails.FindSet() then
            repeat
                // Clear(ConsignSalesMissing);
                ConsignSalesMissing.Init();
                ConsignSalesMissing.TransferFields(ConsignSalesDetails);
                ConsignSalesMissing.Insert(true);

                ConsignSalesDetails.Delete();

            until ConsignSalesDetails.Next() = 0;
    end;

}
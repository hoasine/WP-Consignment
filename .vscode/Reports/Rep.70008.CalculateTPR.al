report 70008 "Calculate TPR"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("TPR Header"; "TPR Header")
        {
            UseTemporary = true;
            RequestFilterFields = "Batch No.", "Store No.", Date, "Item No. Filters", "Division Filters", "Item Category Filters", "Retail Product Group Filters", "Item Type Filters", "Special Group Filters";

            trigger OnPreDataItem()
            begin
                PassParam("TPR Header".GetFilter("Batch No."), "TPR Header".GetFilter("Store No."), "TPR Header".GetRangeMax("Date"),
                    "TPR Header".GetFilter("Item No. Filters"), "TPR Header".GetFilter("Division Filters"), "TPR Header".GetFilter("Item Category Filters"),
                    "TPR Header".GetFilter("Retail Product Group Filters"), "TPR Header".GetRangeMax("Item Type Filters"), "TPR Header".GetFilter("Special Group Filters"));

                Sleep(1000);
                TPRHdr.Reset();
                TPRHdr.SetRange("Batch No.", gBatchNo);
                if TPRHdr.FindFirst() then begin
                    TPRHdr."Last Calculated Date" := 0DT;
                    TPRHdr.Status := 'Calculating...';
                    TPRHdr.Modify();
                end;
            end;

            trigger OnPostDataItem()
            begin
                CalcTradingProfit();
                Sleep(1000);
                TPRHdr.Reset();
                TPRHdr.SetRange("Batch No.", gBatchNo);
                if TPRHdr.FindFirst() then begin
                    TPRHdr."Last Calculated Date" := CurrentDateTime;
                    TPRHdr.Status := 'Completed';
                    TPRHdr.Modify();
                end;
                Sleep(1000);
            end;
        }
    }

    procedure PassParam(pBatchNo: Code[20]; pStore: Code[20]; pDate: Date; pItemNo: Code[100]; pDivision: Code[20]; pItemCategory: code[20]; pProdGrp: Code[20]; pItemType: Enum itemType; pSpecialGroup: Code[20])
    begin
        gBatchNo := pBatchNo;
        gStoreNo := pStore;
        gDate := pDate;
        gItemNo := pItemNo;
        gDivision := pDivision;
        gItemCategory := pItemCategory;
        gProdGrp := pProdGrp;
        gGenProdPostGroup := Format(pItemType);
        gSpecialGroup := pSpecialGroup;
    end;

    procedure CalcTradingProfit()
    var
        recTPF: Record TPR;
        store: Record "LSC Store";
        item: Record Item;
        specialGrp: Record "LSC Item/Special Group Link";
        endDate: Date;
        startDate: Date;
        firstDayofYear: Date;
        gdialog: Dialog;
        iCount: Integer;
        startTime: DateTime;
    begin
        iCount := 0;
        endDate := gDate;
        startDate := CalcDate('-CM', endDate);
        firstDayofYear := CalcDate('-CY', gDate);

        recTPF.Reset();
        recTPF.SetRange("Batch No.", gBatchNo);
        if not recTPF.IsEmpty then
            recTPF.DeleteAll();

        if GuiAllowed then
            gdialog.Open('Inserting TPF Records...\' + 'Records : #1######## / #2########' + 'Duration : #3#########');

        startTime := CurrentDateTime;

        item.Reset();
        if gItemNo <> '' then item.SetFilter("No.", gItemNo);
        if gStoreNo <> '' then item.SetRange("LSC Store Filter", gStoreNo);
        if gDivision <> '' then item.SetFilter("LSC Division Code", gDivision);
        if gItemCategory <> '' then item.SetFilter("Item Category Code", gItemCategory);
        if gProdGrp <> '' then item.SetFilter("LSC Retail Product Code", gProdGrp);
        if gGenProdPostGroup = 'CONSIGN' then item.SetFilter("Gen. Prod. Posting Group", 'CON*');
        if gGenProdPostGroup = 'OUTRIGHT' then item.SetFilter("Gen. Prod. Posting Group", 'OUT*');
        if gGenProdPostGroup = 'CONSIGN & OUTRIGHT' then item.SetFilter("Gen. Prod. Posting Group", 'CON*|OUT*');
        if GuiAllowed then gdialog.Update(2, item.Count);
        item.SetLoadFields(Description, "LSC Division Code", "Item Category Code", "LSC Retail Product Code", "Gen. Prod. Posting Group", "Gen. Prod. Posting Group");
        if item.FindSet() then
            repeat
                specialGrp.Reset();
                specialGrp.SetFilter("Item No.", item."No.");
                if gSpecialGroup <> '' then
                    specialGrp.SetFilter("Special Group Code", gSpecialGroup)
                else
                    specialGrp.SetFilter("Special Group Code", 'B*');
                specialGrp.SetAutoCalcFields("Special Group Name");
                if specialGrp.FindSet() then
                    repeat
                        iCount += 1;
                        if GuiAllowed then begin
                            gdialog.Update(1, iCount);
                            gdialog.Update(3, CurrentDateTime - startTime);
                        end;

                        CalcMTD('MTD-COST', startDate, endDate, item, specialGrp);
                        CalcMTD('MTD-RETAIL', startDate, endDate, item, specialGrp);
                        CalcYTD('YTD-COST', firstDayofYear, endDate, item, specialGrp);
                        CalcYTD('YTD-RETAIL', firstDayofYear, endDate, item, specialGrp);
                    until specialGrp.Next() = 0;
            until item.Next() = 0;
        if GuiAllowed then gdialog.Close();
    end;

    local procedure InitRecord(pType: Text; pStartDate: Date; pEndDate: Date; pItem: Record Item; pSpecialGrp: Record "LSC Item/Special Group Link")
    begin
        TPR.Init();
        TPR."Batch No." := gBatchNo;
        TPR.Type := pType;
        TPR."Start Date" := pStartDate;
        TPR."End Date" := pEndDate;
        TPR."Item No." := pItem."No.";
        TPR.Description := pItem.Description;
        TPR."Special Group Code" := pSpecialGrp."Special Group Code";
        TPR."Special Group Desc" := pSpecialGrp."Special Group Name";
        TPR.Division := pItem."LSC Division Code";
        TPR."Item Category" := pItem."Item Category Code";
        TPR."Retail Product Group" := pItem."LSC Retail Product Code";
        if CopyStr(pItem."Gen. Prod. Posting Group", 1, 3) = 'CON' then TPR."Item Type" := 'CONSIGN';
        if CopyStr(pItem."Gen. Prod. Posting Group", 1, 3) = 'OUT' then TPR."Item Type" := 'OUTRIGHT';
        TPR."Store No." := gStoreNo;
    end;

    local procedure CalcMTD(pType: Text; pStartDate: Date; pEndDate: Date; pItem: Record Item; pSpecialGrp: Record "LSC Item/Special Group Link")
    begin
        InitRecord(pType, pStartDate, pEndDate, pItem, pSpecialGrp);
        CalcSalesCost(pStartDate, pEndDate);

        if TPR."Item Type" = 'OUTRIGHT' then begin
            CalcOpeningInventory(pstartDate, pEndDate);
            CalcIncreaseDecrease('Net Purchase', pStartDate, pEndDate);
            CalcIncreaseDecrease('Markdown', pStartDate, pEndDate);
            CalcIncreaseDecrease('Stock Loss', pStartDate, pEndDate);
        end;
        clearDuplicate(pStartDate, pEndDate);
        TPR.Insert();
    end;

    local procedure CalcYTD(pType: Text; pStartDate: Date; pEndDate: Date; pItem: Record Item; pSpecialGrp: Record "LSC Item/Special Group Link")
    begin
        InitRecord(pType, pStartDate, pEndDate, pItem, pSpecialGrp);
        CalcSalesCost(pStartDate, pEndDate);

        if TPR."Item Type" = 'OUTRIGHT' then begin
            CalcOpeningInventory(pStartDate, pEndDate);
            CalcIncreaseDecrease('Net Purchase', pStartDate, pEndDate);
            CalcIncreaseDecrease('Markdown', pStartDate, pEndDate);
            CalcIncreaseDecrease('Stock Loss', pStartDate, pEndDate);
        end;
        clearDuplicate(pStartDate, pEndDate);
        TPR.Insert();
    end;

    local procedure CalcSalesCost(pstartDate: Date; pEndDate: Date)
    begin
        #region[Outright Sales]
        if (TPR."Item Type" = 'OUTRIGHT') then begin
            Clear(queryCalcTPF);
            queryCalcTPF.SetFilter(ileType, 'Sale');
            queryCalcTPF.SetFilter(filterLocation, gStoreNo);
            queryCalcTPF.SetFilter(filterItem, TPR."Item No.");
            queryCalcTPF.SetFilter(filterDate, '%1..%2', pstartDate, pEndDate);
            if queryCalcTPF.Open() then begin
                while queryCalcTPF.Read do begin
                    TPR."Sales Amount" := queryCalcTPF.salesAmountActual;
                    TPR."Cost Amount" := -queryCalcTPF.costAmountActual;
                    TPR."Net Profit Actual Cost" := TPR."Sales Amount" - TPR."Cost Amount";
                    if (TPR."Sales Amount" <> 0) then
                        TPR."Net Profit Margin" := TPR."Net Profit Actual Cost" / TPR."Sales Amount";
                end;
            end;
        end;
        #endregion

        #region[Consign Sales]
        if TPR."Item Type" = 'CONSIGN' then begin
            Clear(queryGetConsignSales);
            queryGetConsignSales.SetFilter(filterDate, '%1..%2', pStartDate, pEndDate);
            queryGetConsignSales.SetFilter(filterLocation, gStoreNo);
            queryGetConsignSales.SetFilter(filterItem, TPR."Item No.");
            if queryGetConsignSales.Open() then begin
                while queryGetConsignSales.Read do begin
                    TPR."Sales Amount" := queryGetConsignSales.totalExclTax + queryGetConsignSales.discountAmount;
                    TPR."Net Profit Actual Cost" := queryGetConsignSales.profitExclTax;
                    TPR."Cost Amount" := TPR."Sales Amount" - TPR."Net Profit Actual Cost";
                    if (TPR."Sales Amount" <> 0) then begin
                        TPR."Net Profit Margin" := TPR."Net Profit Actual Cost" / TPR."Sales Amount";
                        TPR."Net Purchase Ratio" := TPR."Cost Amount" / TPR."Sales Amount";
                    end;

                    TPR."Net Purchase Actual Cost" := TPR."Cost Amount";
                    TPR."Net Purchase Actual Retail" := TPR."Sales Amount";
                    if (TPR."Net Purchase Actual Retail" <> 0) then
                        TPR."Net Purchase Ratio" := TPR."Net Purchase Actual Cost" / TPR."Net Purchase Actual Retail";
                end;
            end;
        end;
        #endregion
    end;

    local procedure CalcOpeningInventory(pStartDate: Date; pEndDate: Date)
    var
        ValueEntry: Record "Value Entry";
        decPricePerUnit: Decimal;
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type", "Variance Type", "Item Charge No.", "Location Code", "Variant Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Source Type", "Source No.");
        ValueEntry.SetRange("Item No.", TPR."Item No.");
        ValueEntry.SetFilter("Location Code", gStoreNo);
        if (TPR.Type = 'MTD-COST') or (TPR.Type = 'MTD-RETAIL') then
            ValueEntry.SetFilter("Posting Date", '<%1', pStartDate)
        else
            ValueEntry.SetRange("Posting Date", pStartDate, pEndDate);

        ValueEntry.SetLoadFields("Item No.", "Location Code", "Posting Date", "Item Ledger Entry Quantity", "Cost Amount (Actual)", "Sales Amount (Actual)", "Item Ledger Entry Type");
        ValueEntry.CalcSums("Item Ledger Entry Quantity", "Cost Amount (Actual)", "Sales Amount (Actual)");

        TPR."Opening Inv Qty" := ValueEntry."Item Ledger Entry Quantity";
        TPR."Opening Inv Actual Cost" := ValueEntry."Cost Amount (Actual)";

        ValueEntry.SetFilter("Item Ledger Entry Type", 'Sale');
        ValueEntry.CalcSums("Item Ledger Entry Quantity", "Cost Amount (Actual)", "Sales Amount (Actual)");
        Clear(decPricePerUnit);
        if (ValueEntry."Item Ledger Entry Quantity" <> 0) then begin
            decPricePerUnit := valueEntry."Sales Amount (Actual)" / ValueEntry."Item Ledger Entry Quantity";
            TPR."Price Per Unit" := decPricePerUnit * -1;
        end;

        TPR."Opening Inv Actual Retail" := TPR."Price Per Unit" * TPR."Opening Inv Qty";
        if (TPR."Opening Inv Actual Retail" <> 0) then TPR."Opening Inv Ratio" := TPR."Opening Inv Actual Cost" / TPR."Opening Inv Actual Retail";
    end;

    local procedure CalcIncreaseDecrease(pType: Text; pStartDate: Date; pEndDate: Date)
    var
        decQty: Decimal;
        decNetPurchActual: Decimal;
        decMarkdown: Decimal;
        decStockLoss: Decimal;
    begin
        #region[Outright]

        Clear(decQty);
        Clear(decNetPurchActual);
        Clear(decMarkdown);
        Clear(decStockLoss);

        Clear(queryCalcTPF);
        queryCalcTPF.SetFilter(filterLocation, gStoreNo);
        queryCalcTPF.SetFilter(filterItem, TPR."Item No.");
        queryCalcTPF.SetFilter(filterDate, '%1..%2', pstartDate, pEndDate);
        if (pType = 'Net Purchase') then queryCalcTPF.SetFilter(ileType, 'Purchase|Transfer');
        if (pType = 'Stock Loss') then queryCalcTPF.SetFilter(ileType, 'Positive Adjmt.|Negative Adjmt.');
        if queryCalcTPF.Open() then begin
            while queryCalcTPF.Read do begin
                decQty := queryCalcTPF.quantity;
                decNetPurchActual := queryCalcTPF.costAmountActual;
                decMarkdown := queryCalcTPF.discountAmount;
                decStockLoss := queryCalcTPF.costAmountActual;
            end;
        end;

        //netPurchase-
        if (pType = 'Net Purchase') then begin
            TPR."Net Purchase Qty" := -decQty;
            TPR."Net Purchase Actual Cost" := decNetPurchActual;
            TPR."Net Purchase Actual Retail" := -TPR."Net Purchase Qty" * TPR."Price Per Unit";
            if (TPR."Net Purchase Actual Retail" <> 0) then TPR."Net Purchase Ratio" := TPR."Net Purchase Actual Cost" / TPR."Net Purchase Actual Retail";
        end;
        //netPurchase+

        //Markdown-
        if (pType = 'Markdown') then begin
            TPR."Markdown Actual" := -decMarkdown;
            if (TPR."Markdown Actual" <> 0) and (TPR."Sales Amount" <> 0) then
                TPR."Markdown Ratio" := TPR."Markdown Actual" / TPR."Sales Amount";
            //Markdown+
        end;
        //StockLoss-
        if (pType = 'Stock Loss') then begin
            TPR."Stock Loss Qty" := -decQty;
            TPR."Stock Loss Actual Cost" := -decStockLoss;
            TPR."Stock Loss Actual Retail" := TPR."Stock Loss Qty" * TPR."Price Per Unit";
            if TPR."Stock Loss Actual Retail" <> 0 then TPR."Stock Loss Ratio" := TPR."Stock Loss Actual Cost" / TPR."Stock Loss Actual Retail";
            //StockLoss+
        end;

        //endingInventory-
        TPR."Ending Inv Actual Cost" := TPR."Opening Inv Actual Cost" + TPR."Net Purchase Actual Cost" + TPR."Stock Loss Actual Cost" - TPR."Cost Amount";
        TPR."Ending Inv Actual Retail" := round(TPR."Opening Inv Actual Retail" + TPR."Net Purchase Actual Retail" - TPR."Sales Amount");
        if (TPR."Ending Inv Actual Retail" <> 0) then TPR."Ending Inv Ratio" := TPR."Ending Inv Actual Cost" / TPR."Ending Inv Actual Retail";
        //endingInventory+
        #endregion
    end;

    local procedure clearDuplicate(pStartDate: Date; pEndDate: Date)
    begin
        if TPR.Type = 'MTD-COST' then begin
            TPR."Opening Inventory" := TPR."Opening Inv Actual Cost";
            TPR."Net Purchase" := TPR."Net Purchase Actual Cost";
            TPR."Stock Loss" := TPR."Stock Loss Actual Cost";
            TPR."Ending Inventory" := TPR."Ending Inv Actual Cost";
        end;

        if TPR.Type = 'MTD-RETAIL' then begin
            TPR."Opening Inventory" := TPR."Opening Inv Actual Retail";
            TPR."Opening Inv Ratio" := 0;
            TPR."Net Purchase" := TPR."Net Purchase Actual Retail";
            TPR."Net Purchase Ratio" := 0;
            TPR."Stock Loss" := TPR."Stock Loss Actual Retail";
            TPR."Ending Inventory" := TPR."Ending Inv Actual Retail";
            TPR."Sales Amount" := 0;
            TPR."Cost Amount" := 0;
            TPR."Net Profit Actual Cost" := 0;
            TPR."Net Profit Margin" := 0;
            TPR."Markdown Actual" := 0;
            TPR."Markdown Ratio" := 0;
            TPR."Stock Loss Ratio" := 0;
            TPR."Ending Inv Ratio" := 0;
        end;

        if TPR.Type = 'YTD-COST' then begin
            TPR."Opening Inv Actual Cost" := 0;
            TPR."Opening Inv Actual Retail" := 0;
            TPR."Opening Inv Ratio" := 0;
            TPR."Net Purchase" := TPR."Net Purchase Actual Cost";
            TPR."Stock Loss" := TPR."Stock Loss Actual Cost";
            TPR."Ending Inv Actual Cost" := 0;
            TPR."Ending Inv Actual Retail" := 0;
            TPR."Ending Inv Ratio" := 0;
        end;

        if TPR.Type = 'YTD-RETAIL' then begin
            TPR."Sales Amount" := 0;
            TPR."Cost Amount" := 0;
            TPR."Net Profit Actual Cost" := 0;
            TPR."Net Profit Margin" := 0;
            TPR."Opening Inv Actual Cost" := 0;
            TPR."Opening Inv Actual Retail" := 0;
            TPR."Opening Inv Ratio" := 0;
            TPR."Net Purchase" := TPR."Net Purchase Actual Retail";
            TPR."Net Purchase Ratio" := 0;
            TPR."Stock Loss" := TPR."Stock Loss Actual Retail";
            TPR."Markdown Actual" := 0;
            TPR."Markdown Ratio" := 0;
            TPR."Stock Loss Ratio" := 0;
            TPR."Ending Inv Actual Cost" := 0;
            TPR."Ending Inv Actual Retail" := 0;
            TPR."Ending Inv Ratio" := 0;
        end;
    end;


    var
        TPR: Record TPR;
        TPRHdr: Record "TPR Header";
        queryCalcTPF: Query CalcTPRSales;
        queryGetConsignSales: Query GetConsignSales;
        gBatchNo: Code[20];
        gStoreNo: Code[20];
        gDate: Date;
        gItemNo: Code[100];
        gDivision: Code[20];
        gItemCategory: code[20];
        gProdGrp: Code[20];
        gGenProdPostGroup: Code[20];
        gSpecialGroup: Code[20];


}
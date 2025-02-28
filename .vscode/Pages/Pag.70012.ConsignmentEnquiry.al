page 70012 "Consignment Enquiry"
{
    Caption = 'Consignment Enquiry';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Consignment Header";
    SaveValues = false;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Filter Options';
                field(DocNoFilter; DocNoFilter)
                {
                    Caption = 'Document No.';
                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Document No.", DocNoFilter);
                        if Rec.FindFirst() then
                            CurrPage.Update(false);
                    end;
                }
                field(VendNoFilter; VendNoFilter)
                {
                    Caption = 'Vendor No.';
                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Vendor No.", VendNoFilter);
                        if Rec.FindFirst() then
                            CurrPage.Update(false);
                    end;
                }
                field(ConsignmentPeriodStartDate; ConsignmentPeriodStartDate)
                {
                    Caption = 'Start Date';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        BillingPeriod: Record "WP B.Inc Billing Periods";

                    begin
                        BillingPeriod.Reset();
                        if Page.RunModal(Page::"WP Billing Periods", BillingPeriod) = Action::LookupOK then begin
                            ConsignmentPeriodStartDate := BillingPeriod."Start Date";
                            ConsignmentPeriodEndDate := BillingPeriod."End Date";
                        end;
                    end;
                }
                field(ConsignmentPeriodEndDate; ConsignmentPeriodEndDate)
                {
                    Caption = 'End Date';
                    Editable = false;
                }
                field(StatusFilter; StatusFilter)
                {
                    Caption = 'Status';
                    OptionCaption = 'Open,Released,Posted';
                }
                field(Discrepancy; Discrepancy)
                {
                    trigger OnValidate()
                    begin
                        if Discrepancy then
                            Rec.SetRange(Discrepancy, true);

                        if not Discrepancy then
                            Rec.SetRange(Discrepancy, false);

                        if Rec.FindFirst() then
                            CurrPage.Update(false);
                    end;
                }
            }
            repeater(Details)
            {
                Editable = false;
                FreezeColumn = Status;
                field(Rec; Rec."Document No.") { Width = 17; }
                field("Vendor No."; Rec."Vendor No.") { }
                field(VendorName; Vendor.Name) { Caption = 'Vendor Name'; }
                field("Start Date"; Rec."Start Date") { }
                field("End Date"; Rec."End Date") { }
                field(Status; Rec.Status) { }
                field(LineDiscrepancy; Rec.Discrepancy) { Caption = 'Discrepancy'; }
                field("No. of Lines"; Rec."No. of Lines") { Caption = 'Total Consignment Lines'; }
                field("Total Excl. Tax"; Rec."Total Excl. Tax") { Caption = 'Total Consignment Sales Amount'; }
                field(LineTotalStorePosted; Rec."Total Store Posted") { Caption = 'Total Store Posted'; }
                field(LineTotalPostedSalesAmount; Rec."Total Store Posted Amount") { Caption = 'Total Posted Sales Amount'; }
                field(LineTotalStoreUnposted; Rec."Total Store UnPosted") { Caption = 'Total Store Unposted'; Style = Attention; }
                field(LineTotalUnpostedSalesAmount; Rec."Total Store UnPosted Amount") { Caption = 'Total Unposted Sales Amount'; Style = Attention; }
                field(TotalCost; Rec."Billing - Total Cost") { Caption = 'Total Cost'; }
                field(TotalProfit; Rec."Billing - Total Profit") { Caption = 'Total Profit'; }
                field(TotalSIAmount; Rec."Billing - Total Profit") { Caption = 'Total SI Amount'; }
                field(TotalPIAmount; Rec."Billing - Total Exc. Tax") { Caption = 'Total PI Amount'; }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.") { }
                field("Posted Purchase Invoice No."; Rec."Posted Purchase Invoice No.") { }
                field("Sales Invoice No."; Rec."Sales Invoice No.") { }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Function_GetConsignmentDoc)
            {
                Caption = 'Get &Consignment Documents';
                ApplicationArea = All;
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    GetConsignmentDocs();
                end;
            }
        }
        area(Navigation)
        {
            action(ConsignDoc)
            {
                Caption = 'Consignment Document';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Consignment Document";
                RunPageLink = "Document No." = field("Document No.");
            }
            action(PurchInv)
            {
                Caption = 'Purchase Invoice';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Purchase Invoice";
                RunPageLink = "No." = field("Purchase Invoice No.");
            }
            action(PostedPurchInv)
            {
                Caption = 'Posted Purchase Invoice';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Purchase Invoice";
                RunPageLink = "No." = field("Posted Purchase Invoice No.");
            }
            action(SalesInv)
            {
                Caption = 'Sales Invoice';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Sales Invoice";
                RunPageLink = "No." = field("Sales Invoice No.");
            }
            action(PostedSalesInv)
            {
                Caption = 'Posted Sales Invoice';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Posted Sales Invoice";
                RunPageLink = "No." = field("Posted Sales Invoice No.");
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        Vendor.Reset();
        Vendor.SetLoadFields(Name);
        if Vendor.Get(Rec."Vendor No.") then;
    end;

    local procedure GetConsignmentDocs()
    var
        useQuery: Boolean;
        GetConsignPostedSalesQuery: Query "SelectConsignPostedSales"; //total posted sales
        GetConsignSalesQuery: Query "SelectConsignSales"; //total sales
        GetConsignPostedTransCountQuery: Query "SelectConsignPostedTransCount";
        GetConsignTransCountQuery: Query "SelectConsignTransCount";
        ConsignGroup: Text;
        transno: Integer;
        RecTS: Record "LSC Transaction Status" temporary;
        RecTSTemp: Record "LSC Transaction Status" temporary;
        RecTSTemp2: Record "LSC Transaction Status" temporary;
        RecTSTemp3: Record "LSC Transaction Status" temporary;
        //RecTSTemp4: Record "LSC Transaction Status" temporary;
        RecTH: Record "LSC Transaction Header" temporary;
        RecTHTemp: Record "LSC Transaction Header" temporary;
        RecTHTemp2: Record "LSC Transaction Header" temporary;
        i: Integer;
        gdiag: Dialog;

    begin
        rec.Reset();
        rec.DeleteAll();
        ConsignmentDoc.Reset();
        if DocNoFilter <> '' then ConsignmentDoc.SetFilter("Document No.", DocNoFilter);
        if VendNoFilter <> '' then ConsignmentDoc.SetFilter("Vendor No.", VendNoFilter);
        if Format(StatusFilter) <> '' then ConsignmentDoc.SetFilter(Status, Format(StatusFilter));
        if ConsignmentPeriodStartDate <> 0D then ConsignmentDoc.SetFilter("Start Date", '>=%1', ConsignmentPeriodStartDate);
        if ConsignmentPeriodEndDate <> 0D then ConsignmentDoc.SetFilter("End Date", '<=%1', ConsignmentPeriodEndDate);
        if ConsignmentDoc.FindSet() then begin
            ConsignmentDoc.SetAutoCalcFields("Total Excl. Tax", "Billing - Total Cost", "Billing - Total Profit", "Billing - Total Exc. Tax");
            repeat
                Rec.Init();
                Rec := ConsignmentDoc;
                Rec.Insert();
            until ConsignmentDoc.Next() = 0;
        end;

        if (DocNoFilter <> '') or (VendNoFilter <> '') then
            useQuery := false
        else
            useQuery := true;

        if Rec.FindSet() then begin
            if useQuery = false then begin
                repeat
                    CalcTSEStatus();
                until Rec.Next() = 0;
            end else begin
                //By Query-
                if GuiAllowed then begin
                    gdiag.Open('Working on it...\' + '#1#########\ Records : #2########');
                    gdiag.Update(1, 'Getting Sales Records');
                end;

                Clear(RecTSTemp);
                transno := 0;
                i := 0;

                ConsignGroup := GetConsignPostGroup();
                GetConsignPostedSalesQuery.SetFilter(Filter_Date, '%1..%2', ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
                GetConsignPostedSalesQuery.SetFilter(Filter_Gen__Prod__Posting_Group, ConsignGroup);
                if GetConsignPostedSalesQuery.Open then begin
                    while GetConsignPostedSalesQuery.Read do begin

                        gdiag.Update(1, 'Inserting Posted Sales Transactions');
                        gdiag.Update(2, Format(i));

                        RecTS.Reset;
                        RecTS."Store No." := 'TEMP';
                        RecTS."POS Terminal No." := 'TEMP';
                        RecTS."Transaction No." := transno;
                        RecTS.Status := GetConsignPostedSalesQuery.Status;
                        RecTS."Sales Amount" := GetConsignPostedSalesQuery."TSE_Sum_Excl_Tax";
                        RecTS."VAT Amount" := GetConsignPostedSalesQuery.TSE_Sum_Tax;
                        RecTS."No of Trans. Sales Entries" := GetConsignPostedSalesQuery.TSE_Sum_Qty;
                        RecTS."Customer No." := GetConsignPostedSalesQuery.Vendor_No_;
                        RecTS."Statement No." := GetConsignPostedSalesQuery.Gen__Prod__Posting_Group;
                        RecTS."Inv. Transaction" := GetConsignPostedSalesQuery.Count;

                        RecTSTemp := RecTS;
                        RecTSTemp.Insert();

                        transno += 1;
                        i += 1;
                    end;
                end;

                Clear(RecTSTemp2);
                transno := 0;
                i := 0;

                GetConsignSalesQuery.SetFilter(Filter_Date, '%1..%2', ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
                GetConsignSalesQuery.SetFilter(Filter_Gen__Prod__Posting_Group, ConsignGroup);
                if GetConsignSalesQuery.Open then begin
                    while GetConsignSalesQuery.Read do begin

                        gdiag.Update(1, 'Inserting Sales Transactions');
                        gdiag.Update(2, Format(i));

                        RecTS.Reset;
                        RecTS."Store No." := 'TEMP';
                        RecTS."POS Terminal No." := 'TEMP';
                        RecTS."Transaction No." := transno;
                        RecTS."Customer No." := GetConsignSalesQuery.Vendor_No_;
                        RecTS."Sales Amount" := GetConsignSalesQuery."Net_Amount";
                        RecTS."No of Trans. Sales Entries" := GetConsignSalesQuery.Count;

                        RecTSTemp2 := RecTS;
                        RecTSTemp2.Insert();

                        transno += 1;
                        i += 1;
                    end;
                end;

                Clear(RecTHTemp);
                transno := 0;
                i := 0;

                //GetConsignPostedTransCountQuery.set
                GetConsignPostedTransCountQuery.SetFilter(Filter_Date, '%1..%2', ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
                GetConsignPostedTransCountQuery.SetFilter(Filter_Gen__Prod__Posting_Group, ConsignGroup);
                if GetConsignPostedTransCountQuery.Open then begin
                    while GetConsignPostedTransCountQuery.Read do begin

                        gdiag.Update(1, 'Inserting Posted Transactions Count');
                        gdiag.Update(2, Format(i));

                        RecTH.Reset;
                        RecTH."Store No." := 'TEMP';
                        RecTH."POS Terminal No." := 'TEMP';
                        RecTH."Transaction No." := transno;
                        RecTH.Date := GetConsignPostedTransCountQuery.Date;
                        RecTH."Receipt No." := GetConsignPostedTransCountQuery.Receipt_No_;
                        RecTH."Customer No." := GetConsignPostedTransCountQuery.Vendor_No_;
                        if GetConsignPostedTransCountQuery.Status = RecTS.Status::" " then begin
                            RecTH."No. of Items" := 0;
                        end else
                            if GetConsignPostedTransCountQuery.Status = RecTS.Status::"Items Posted" then begin
                                RecTH."No. of Items" := 1;
                            end else
                                if GetConsignPostedTransCountQuery.Status = RecTS.Status::Posted then begin
                                    RecTH."No. of Items" := 2;
                                end;

                        RecTHTemp := RecTH;
                        RecTHTemp.Insert();

                        transno += 1;
                        i += 1;
                    end;
                end;

                Clear(RecTHTemp2);
                transno := 0;
                i := 0;

                //GetConsignTransCountQuery.set
                GetConsignTransCountQuery.SetFilter(Filter_Date, '%1..%2', ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
                GetConsignTransCountQuery.SetFilter(Filter_Gen__Prod__Posting_Group, ConsignGroup);
                if GetConsignTransCountQuery.Open then begin
                    while GetConsignTransCountQuery.Read do begin

                        gdiag.Update(1, 'Inserting Transactions Count');
                        gdiag.Update(2, Format(i));

                        RecTH.Reset;
                        RecTH."Store No." := 'TEMP';
                        RecTH."POS Terminal No." := 'TEMP';
                        RecTH."Transaction No." := transno;
                        RecTH."Receipt No." := GetConsignTransCountQuery.Receipt_No_;
                        RecTH.Date := GetConsignTransCountQuery.Date;
                        RecTH."Customer No." := GetConsignTransCountQuery.Vendor_No_;

                        RecTHTemp2 := RecTH;
                        RecTHTemp2.Insert();

                        transno += 1;
                        i += 1;
                    end;
                end;

                i := 0;

                repeat
                    Rec."Total Store Posted" := 0;
                    Rec."Total Store Posted Amount" := 0;
                    Rec."Total Store UnPosted" := 0;
                    Rec."Total Store UnPosted Amount" := 0;

                    gdiag.Update(1, 'Updating Consignment Enquiry');
                    gdiag.Update(2, Format(i));

                    //posted sales amount (excl tax)
                    RecTSTemp.SetRange("Customer No.");
                    RecTSTemp.SetRange(Status);
                    RecTSTemp.SetRange("Customer No.", Rec."Vendor No.");
                    RecTSTemp.SetFilter(Status, '%1|%2', RecTSTemp.Status::Posted, RecTSTemp.Status::"Items Posted");
                    if RecTSTemp.FindSet() then begin
                        repeat
                            Rec."Total Store Posted Amount" += RecTSTemp."Sales Amount";
                        until RecTSTemp.Next = 0;

                        Rec."Total Store Posted Amount" := Rec."Total Store Posted Amount" * -1;
                    end;

                    //posted transaction count
                    RecTHTemp.SetRange("Customer No.");
                    RecTHTemp.SetRange("No. of Items");
                    RecTHTemp.SetRange("Customer No.", Rec."Vendor No.");
                    RecTHTemp.SetFilter("No. of Items", '%1|%2', 1, 2);
                    if RecTHTemp.FindSet() then begin
                        Rec."Total Store Posted" := RecTHTemp.Count;
                    end;


                    //unposted sales amount (excl tax)
                    RecTSTemp2.SetRange("Customer No.");
                    RecTSTemp2.SetRange(Status);
                    RecTSTemp2.SetRange("Customer No.", Rec."Vendor No.");
                    if RecTSTemp2.FindSet() then begin
                        repeat
                            Rec."Total Store UnPosted Amount" += RecTSTemp2."Sales Amount";
                        until RecTSTemp2.Next = 0;

                        Rec."Total Store UnPosted Amount" := -(Rec."Total Store UnPosted Amount") - Rec."Total Store Posted Amount";
                    end;

                    //unposted transaction count
                    RecTHTemp2.SetRange("Customer No.");
                    RecTHTemp2.SetRange("Customer No.", Rec."Vendor No.");
                    if RecTHTemp2.FindSet() then begin
                        Rec."Total Store UnPosted" := RecTHTemp2.Count;
                        Rec."Total Store UnPosted" := Rec."Total Store UnPosted" - Rec."Total Store Posted";
                    end;

                    i += 1;
                    Rec.Modify();

                until Rec.Next() = 0;
            end;
            if Rec.FindFirst() then;
            //By Query+
        end;
    end;

    local procedure GetNextTransNo(RecTSE: Record "LSC Trans. Sales Entry"): Integer
    var
        nextnumber: Integer;
    begin
        nextnumber := 0;
        RecTSE.SetRange("Store No.", 'TEMP');
        RecTSE.SetRange("POS Terminal No.", 'TEMP');
        RecTSE.SetAscending("Transaction No.", true);
        if RecTSE.FindLast() then
            nextnumber := RecTSE."Transaction No." + 1
        else
            nextnumber := 1;

        exit(nextnumber);
    end;

    local procedure GetNextLineNo(RecTSE: Record "LSC Trans. Sales Entry"; transno: Integer): Integer
    var
        nextnumber: Integer;
    begin
        nextnumber := 0;
        RecTSE.SetRange("Store No.", 'TEMP');
        RecTSE.SetRange("POS Terminal No.", 'TEMP');
        RecTSE.SetRange("Transaction No.", transno);
        if RecTSE.FindLast() then
            nextnumber := RecTSE."Line No." + 1000
        else
            nextnumber := 1000;

        exit(nextnumber);
    end;

    local procedure CalcTSEStatus()
    var
        TransHeader: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        recItem: Record Item;
        cuConsignUtil: Codeunit "Consignment Util";
        ConsignGroup: Text;
        StoreVendor: Text;
    begin
        ConsignGroup := GetConsignPostGroup();
        Rec."Total Store Posted" := 0;
        Rec."Total Store Posted Amount" := 0;
        Rec."Total Store UnPosted" := 0;
        Rec."Total Store UnPosted Amount" := 0;
        Rec.CalcFields("No. of Lines");

        TransHeader.Reset();
        TransHeader.SetCurrentKey("Store No.", Date);
        TransHeader.SetRange(Date, ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
        TransHeader.SetLoadFields(Date, "Posting Status");
        if TransHeader.FindSet() then begin
            repeat
                TransHeader.CalcFields("Posting Status");
                SalesEntry.Reset();
                SalesEntry.SetCurrentKey(Date, "Item No.");
                SalesEntry.SetRange(Date, ConsignmentPeriodStartDate, ConsignmentPeriodEndDate);
                SalesEntry.SetRange("Store No.", TransHeader."Store No.");
                SalesEntry.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                SalesEntry.SetRange("Transaction No.", TransHeader."Transaction No.");
                if ConsignGroup <> '' then SalesEntry.SetFilter("Gen. Prod. Posting Group", ConsignGroup);
                if SalesEntry.FindSet() then
                    repeat
                        recItem.Reset();
                        recItem.SetLoadFields("Gen. Prod. Posting Group");
                        recItem.SetFilter("Gen. Prod. Posting Group", ConsignGroup);
                        if recItem.Get(SalesEntry."Item No.") then begin
                            if ConsignGroup <> '' then begin
                                //if recItem."Gen. Prod. Posting Group" = ConsignGroup then begin
                                Clear(cuConsignUtil);

                                // clear(StoreVendor);
                                // StoreVendor := cuConsignUtil.GetVendorCode(SalesEntry);
                                StoreVendor := recItem."Vendor No.";

                                if StoreVendor <> '' then begin
                                    if StoreVendor = Rec."Vendor No." then begin
                                        if (TransHeader."Posting Status" = TransHeader."Posting Status"::Posted) Or
                                         (TransHeader."Posting Status" = TransHeader."Posting Status"::"Items Posted") then begin
                                            Rec."Total Store Posted" += 1;
                                            Rec."Total Store Posted Amount" += -SalesEntry."Net Amount";
                                        end;
                                        if TransHeader."Posting Status" = TransHeader."Posting Status"::" " then begin
                                            Rec."Total Store UnPosted" += 1;
                                            Rec."Total Store UnPosted Amount" += -SalesEntry."Net Amount";
                                        end;
                                    end;
                                end;
                                //end;
                            end;
                        end;
                        if Rec."No. of Lines" <> Rec."Total Store Posted" then
                            Rec.Discrepancy := true
                        else
                            Rec.Discrepancy := false;

                        Rec.Modify();
                    until SalesEntry.Next() = 0;
            until TransHeader.Next() = 0;
        end;
    end;

    procedure GetConsignPostGroup(): Text[250]
    begin
        if RetailSetup.Get() then
            exit(RetailSetup."Consign. Prod. Posting Groups");
    end;

    var
        Vendor: Record Vendor;
        ConsignmentDoc: Record "Consignment Header";
        RetailSetup: Record "LSC Retail Setup";
        DocNoFilter: Text;
        VendNoFilter: Text;
        StatusFilter: Option;
        ConsignmentPeriodStartDate: Date;
        ConsignmentPeriodEndDate: Date;
        Discrepancy: Boolean;
}
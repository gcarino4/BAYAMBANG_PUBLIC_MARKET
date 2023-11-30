/*
 * This file is auto-generated.  DO NOT MODIFY.
 */
package net.nyx.printerservice.print;
public interface IPrinterService extends android.os.IInterface
{
  /** Default implementation for IPrinterService. */
  public static class Default implements net.nyx.printerservice.print.IPrinterService
  {
    @Override public java.lang.String getServiceVersion() throws android.os.RemoteException
    {
      return null;
    }
    @Override public int getPrinterVersion(java.lang.String[] ver) throws android.os.RemoteException
    {
      return 0;
    }
    @Override public int getPrinterModel(java.lang.String[] model) throws android.os.RemoteException
    {
      return 0;
    }
    @Override public int getPrinterStatus() throws android.os.RemoteException
    {
      return 0;
    }
    @Override public int paperOut(int px) throws android.os.RemoteException
    {
      return 0;
    }
    @Override public int paperBack(int px) throws android.os.RemoteException
    {
      return 0;
    }
    @Override public int printText(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Print text
         *
         * @param text       text content
         * @param textFormat text format
         * @param textWidth  maximum text width, <384px
         * @param align      The alignment of the maximum text width relative to the 384px printing paper
         *                   The default is 0. 0--Align left, 1--Align center, 2--Align right
         * @return Print result
         */
    @Override public int printText2(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat, int textWidth, int align) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Print barcode
         *
         * @param content      barcode content
         * @param width        barcode width, px
         * @param height       barcode height, px
         * @param textPosition barcode content text position, the default is 0.
         *                     0--don't print barcode content
         *                     1--content above the barcode
         *                     2--content below the barcode
         *                     3--text print both the top and bottom of the barcode
         * @param align        alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
         * @return Print result
         */
    @Override public int printBarcode(java.lang.String content, int width, int height, int textPosition, int align) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Print QR code
         *
         * @param content QRCode content
         * @param width   QRCode width, px
         * @param height  QRCode height, px
         * @param align   alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
         * @return Print result
         */
    @Override public int printQrCode(java.lang.String content, int width, int height, int align) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Print bitmap
         *
         * @param bitmap Android bitmap object
         * @param type   printer render type, the default is 0.
         *               0--black and white bitmap
         *               1--grayscale bitmap, suitable for rich color images
         * @param align  alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
         * @return Print result
         */
    @Override public int printBitmap(android.graphics.Bitmap bitmap, int type, int align) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Locate the next label
         *
         * @param labelHeight label paper height, px
         * @param labelGap    label paper gap, px
         * @return Result
         */
    @Override public int labelLocate(int labelHeight, int labelGap) throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Label printing ends, paper automatically moves to the tear-off position.
         * This method must appear in pairs with {@link #labelLocate}
         *
         * @return Result
         */
    @Override public int labelPrintEnd() throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Auto locate label. This method only can be called on the system that has performed
         * label learning by {@link #labelDetectAuto}
         *
         * @return Result
         */
    @Override public int labelLocateAuto() throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Label learning by automatic label detection. This method will start label learning
         *
         * @return Result
         */
    @Override public int labelDetectAuto() throws android.os.RemoteException
    {
      return 0;
    }
    /**
         * Label learning has been performed
         *
         * @return Result
         */
    @Override public boolean hasLabelLearning() throws android.os.RemoteException
    {
      return false;
    }
    /**
         * Clear label learning data
         *
         * @return Result
         */
    @Override public int clearLabelLearning() throws android.os.RemoteException
    {
      return 0;
    }
    @Override
    public android.os.IBinder asBinder() {
      return null;
    }
  }
  /** Local-side IPC implementation stub class. */
  public static abstract class Stub extends android.os.Binder implements net.nyx.printerservice.print.IPrinterService
  {
    private static final java.lang.String DESCRIPTOR = "net.nyx.printerservice.print.IPrinterService";
    /** Construct the stub at attach it to the interface. */
    public Stub()
    {
      this.attachInterface(this, DESCRIPTOR);
    }
    /**
     * Cast an IBinder object into an net.nyx.printerservice.print.IPrinterService interface,
     * generating a proxy if needed.
     */
    public static net.nyx.printerservice.print.IPrinterService asInterface(android.os.IBinder obj)
    {
      if ((obj==null)) {
        return null;
      }
      android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
      if (((iin!=null)&&(iin instanceof net.nyx.printerservice.print.IPrinterService))) {
        return ((net.nyx.printerservice.print.IPrinterService)iin);
      }
      return new net.nyx.printerservice.print.IPrinterService.Stub.Proxy(obj);
    }
    @Override public android.os.IBinder asBinder()
    {
      return this;
    }
    @Override public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException
    {
      java.lang.String descriptor = DESCRIPTOR;
      switch (code)
      {
        case INTERFACE_TRANSACTION:
        {
          reply.writeString(descriptor);
          return true;
        }
        case TRANSACTION_getServiceVersion:
        {
          data.enforceInterface(descriptor);
          java.lang.String _result = this.getServiceVersion();
          reply.writeNoException();
          reply.writeString(_result);
          return true;
        }
        case TRANSACTION_getPrinterVersion:
        {
          data.enforceInterface(descriptor);
          java.lang.String[] _arg0;
          int _arg0_length = data.readInt();
          if ((_arg0_length<0)) {
            _arg0 = null;
          }
          else {
            _arg0 = new java.lang.String[_arg0_length];
          }
          int _result = this.getPrinterVersion(_arg0);
          reply.writeNoException();
          reply.writeInt(_result);
          reply.writeStringArray(_arg0);
          return true;
        }
        case TRANSACTION_getPrinterModel:
        {
          data.enforceInterface(descriptor);
          java.lang.String[] _arg0;
          int _arg0_length = data.readInt();
          if ((_arg0_length<0)) {
            _arg0 = null;
          }
          else {
            _arg0 = new java.lang.String[_arg0_length];
          }
          int _result = this.getPrinterModel(_arg0);
          reply.writeNoException();
          reply.writeInt(_result);
          reply.writeStringArray(_arg0);
          return true;
        }
        case TRANSACTION_getPrinterStatus:
        {
          data.enforceInterface(descriptor);
          int _result = this.getPrinterStatus();
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_paperOut:
        {
          data.enforceInterface(descriptor);
          int _arg0;
          _arg0 = data.readInt();
          int _result = this.paperOut(_arg0);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_paperBack:
        {
          data.enforceInterface(descriptor);
          int _arg0;
          _arg0 = data.readInt();
          int _result = this.paperBack(_arg0);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_printText:
        {
          data.enforceInterface(descriptor);
          java.lang.String _arg0;
          _arg0 = data.readString();
          net.nyx.printerservice.print.PrintTextFormat _arg1;
          if ((0!=data.readInt())) {
            _arg1 = net.nyx.printerservice.print.PrintTextFormat.CREATOR.createFromParcel(data);
          }
          else {
            _arg1 = null;
          }
          int _result = this.printText(_arg0, _arg1);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_printText2:
        {
          data.enforceInterface(descriptor);
          java.lang.String _arg0;
          _arg0 = data.readString();
          net.nyx.printerservice.print.PrintTextFormat _arg1;
          if ((0!=data.readInt())) {
            _arg1 = net.nyx.printerservice.print.PrintTextFormat.CREATOR.createFromParcel(data);
          }
          else {
            _arg1 = null;
          }
          int _arg2;
          _arg2 = data.readInt();
          int _arg3;
          _arg3 = data.readInt();
          int _result = this.printText2(_arg0, _arg1, _arg2, _arg3);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_printBarcode:
        {
          data.enforceInterface(descriptor);
          java.lang.String _arg0;
          _arg0 = data.readString();
          int _arg1;
          _arg1 = data.readInt();
          int _arg2;
          _arg2 = data.readInt();
          int _arg3;
          _arg3 = data.readInt();
          int _arg4;
          _arg4 = data.readInt();
          int _result = this.printBarcode(_arg0, _arg1, _arg2, _arg3, _arg4);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_printQrCode:
        {
          data.enforceInterface(descriptor);
          java.lang.String _arg0;
          _arg0 = data.readString();
          int _arg1;
          _arg1 = data.readInt();
          int _arg2;
          _arg2 = data.readInt();
          int _arg3;
          _arg3 = data.readInt();
          int _result = this.printQrCode(_arg0, _arg1, _arg2, _arg3);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_printBitmap:
        {
          data.enforceInterface(descriptor);
          android.graphics.Bitmap _arg0;
          if ((0!=data.readInt())) {
            _arg0 = android.graphics.Bitmap.CREATOR.createFromParcel(data);
          }
          else {
            _arg0 = null;
          }
          int _arg1;
          _arg1 = data.readInt();
          int _arg2;
          _arg2 = data.readInt();
          int _result = this.printBitmap(_arg0, _arg1, _arg2);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_labelLocate:
        {
          data.enforceInterface(descriptor);
          int _arg0;
          _arg0 = data.readInt();
          int _arg1;
          _arg1 = data.readInt();
          int _result = this.labelLocate(_arg0, _arg1);
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_labelPrintEnd:
        {
          data.enforceInterface(descriptor);
          int _result = this.labelPrintEnd();
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_labelLocateAuto:
        {
          data.enforceInterface(descriptor);
          int _result = this.labelLocateAuto();
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_labelDetectAuto:
        {
          data.enforceInterface(descriptor);
          int _result = this.labelDetectAuto();
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        case TRANSACTION_hasLabelLearning:
        {
          data.enforceInterface(descriptor);
          boolean _result = this.hasLabelLearning();
          reply.writeNoException();
          reply.writeInt(((_result)?(1):(0)));
          return true;
        }
        case TRANSACTION_clearLabelLearning:
        {
          data.enforceInterface(descriptor);
          int _result = this.clearLabelLearning();
          reply.writeNoException();
          reply.writeInt(_result);
          return true;
        }
        default:
        {
          return super.onTransact(code, data, reply, flags);
        }
      }
    }
    private static class Proxy implements net.nyx.printerservice.print.IPrinterService
    {
      private android.os.IBinder mRemote;
      Proxy(android.os.IBinder remote)
      {
        mRemote = remote;
      }
      @Override public android.os.IBinder asBinder()
      {
        return mRemote;
      }
      public java.lang.String getInterfaceDescriptor()
      {
        return DESCRIPTOR;
      }
      @Override public java.lang.String getServiceVersion() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        java.lang.String _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_getServiceVersion, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().getServiceVersion();
          }
          _reply.readException();
          _result = _reply.readString();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int getPrinterVersion(java.lang.String[] ver) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          if ((ver==null)) {
            _data.writeInt(-1);
          }
          else {
            _data.writeInt(ver.length);
          }
          boolean _status = mRemote.transact(Stub.TRANSACTION_getPrinterVersion, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().getPrinterVersion(ver);
          }
          _reply.readException();
          _result = _reply.readInt();
          _reply.readStringArray(ver);
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int getPrinterModel(java.lang.String[] model) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          if ((model==null)) {
            _data.writeInt(-1);
          }
          else {
            _data.writeInt(model.length);
          }
          boolean _status = mRemote.transact(Stub.TRANSACTION_getPrinterModel, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().getPrinterModel(model);
          }
          _reply.readException();
          _result = _reply.readInt();
          _reply.readStringArray(model);
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int getPrinterStatus() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_getPrinterStatus, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().getPrinterStatus();
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int paperOut(int px) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeInt(px);
          boolean _status = mRemote.transact(Stub.TRANSACTION_paperOut, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().paperOut(px);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int paperBack(int px) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeInt(px);
          boolean _status = mRemote.transact(Stub.TRANSACTION_paperBack, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().paperBack(px);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      @Override public int printText(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeString(text);
          if ((textFormat!=null)) {
            _data.writeInt(1);
            textFormat.writeToParcel(_data, 0);
          }
          else {
            _data.writeInt(0);
          }
          boolean _status = mRemote.transact(Stub.TRANSACTION_printText, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().printText(text, textFormat);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Print text
           *
           * @param text       text content
           * @param textFormat text format
           * @param textWidth  maximum text width, <384px
           * @param align      The alignment of the maximum text width relative to the 384px printing paper
           *                   The default is 0. 0--Align left, 1--Align center, 2--Align right
           * @return Print result
           */
      @Override public int printText2(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat, int textWidth, int align) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeString(text);
          if ((textFormat!=null)) {
            _data.writeInt(1);
            textFormat.writeToParcel(_data, 0);
          }
          else {
            _data.writeInt(0);
          }
          _data.writeInt(textWidth);
          _data.writeInt(align);
          boolean _status = mRemote.transact(Stub.TRANSACTION_printText2, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().printText2(text, textFormat, textWidth, align);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Print barcode
           *
           * @param content      barcode content
           * @param width        barcode width, px
           * @param height       barcode height, px
           * @param textPosition barcode content text position, the default is 0.
           *                     0--don't print barcode content
           *                     1--content above the barcode
           *                     2--content below the barcode
           *                     3--text print both the top and bottom of the barcode
           * @param align        alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
           * @return Print result
           */
      @Override public int printBarcode(java.lang.String content, int width, int height, int textPosition, int align) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeString(content);
          _data.writeInt(width);
          _data.writeInt(height);
          _data.writeInt(textPosition);
          _data.writeInt(align);
          boolean _status = mRemote.transact(Stub.TRANSACTION_printBarcode, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().printBarcode(content, width, height, textPosition, align);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Print QR code
           *
           * @param content QRCode content
           * @param width   QRCode width, px
           * @param height  QRCode height, px
           * @param align   alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
           * @return Print result
           */
      @Override public int printQrCode(java.lang.String content, int width, int height, int align) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeString(content);
          _data.writeInt(width);
          _data.writeInt(height);
          _data.writeInt(align);
          boolean _status = mRemote.transact(Stub.TRANSACTION_printQrCode, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().printQrCode(content, width, height, align);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Print bitmap
           *
           * @param bitmap Android bitmap object
           * @param type   printer render type, the default is 0.
           *               0--black and white bitmap
           *               1--grayscale bitmap, suitable for rich color images
           * @param align  alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
           * @return Print result
           */
      @Override public int printBitmap(android.graphics.Bitmap bitmap, int type, int align) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          if ((bitmap!=null)) {
            _data.writeInt(1);
            bitmap.writeToParcel(_data, 0);
          }
          else {
            _data.writeInt(0);
          }
          _data.writeInt(type);
          _data.writeInt(align);
          boolean _status = mRemote.transact(Stub.TRANSACTION_printBitmap, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().printBitmap(bitmap, type, align);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Locate the next label
           *
           * @param labelHeight label paper height, px
           * @param labelGap    label paper gap, px
           * @return Result
           */
      @Override public int labelLocate(int labelHeight, int labelGap) throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          _data.writeInt(labelHeight);
          _data.writeInt(labelGap);
          boolean _status = mRemote.transact(Stub.TRANSACTION_labelLocate, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().labelLocate(labelHeight, labelGap);
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Label printing ends, paper automatically moves to the tear-off position.
           * This method must appear in pairs with {@link #labelLocate}
           *
           * @return Result
           */
      @Override public int labelPrintEnd() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_labelPrintEnd, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().labelPrintEnd();
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Auto locate label. This method only can be called on the system that has performed
           * label learning by {@link #labelDetectAuto}
           *
           * @return Result
           */
      @Override public int labelLocateAuto() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_labelLocateAuto, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().labelLocateAuto();
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Label learning by automatic label detection. This method will start label learning
           *
           * @return Result
           */
      @Override public int labelDetectAuto() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_labelDetectAuto, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().labelDetectAuto();
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Label learning has been performed
           *
           * @return Result
           */
      @Override public boolean hasLabelLearning() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        boolean _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_hasLabelLearning, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().hasLabelLearning();
          }
          _reply.readException();
          _result = (0!=_reply.readInt());
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      /**
           * Clear label learning data
           *
           * @return Result
           */
      @Override public int clearLabelLearning() throws android.os.RemoteException
      {
        android.os.Parcel _data = android.os.Parcel.obtain();
        android.os.Parcel _reply = android.os.Parcel.obtain();
        int _result;
        try {
          _data.writeInterfaceToken(DESCRIPTOR);
          boolean _status = mRemote.transact(Stub.TRANSACTION_clearLabelLearning, _data, _reply, 0);
          if (!_status && getDefaultImpl() != null) {
            return getDefaultImpl().clearLabelLearning();
          }
          _reply.readException();
          _result = _reply.readInt();
        }
        finally {
          _reply.recycle();
          _data.recycle();
        }
        return _result;
      }
      public static net.nyx.printerservice.print.IPrinterService sDefaultImpl;
    }
    static final int TRANSACTION_getServiceVersion = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
    static final int TRANSACTION_getPrinterVersion = (android.os.IBinder.FIRST_CALL_TRANSACTION + 1);
    static final int TRANSACTION_getPrinterModel = (android.os.IBinder.FIRST_CALL_TRANSACTION + 2);
    static final int TRANSACTION_getPrinterStatus = (android.os.IBinder.FIRST_CALL_TRANSACTION + 3);
    static final int TRANSACTION_paperOut = (android.os.IBinder.FIRST_CALL_TRANSACTION + 4);
    static final int TRANSACTION_paperBack = (android.os.IBinder.FIRST_CALL_TRANSACTION + 5);
    static final int TRANSACTION_printText = (android.os.IBinder.FIRST_CALL_TRANSACTION + 6);
    static final int TRANSACTION_printText2 = (android.os.IBinder.FIRST_CALL_TRANSACTION + 7);
    static final int TRANSACTION_printBarcode = (android.os.IBinder.FIRST_CALL_TRANSACTION + 8);
    static final int TRANSACTION_printQrCode = (android.os.IBinder.FIRST_CALL_TRANSACTION + 9);
    static final int TRANSACTION_printBitmap = (android.os.IBinder.FIRST_CALL_TRANSACTION + 10);
    static final int TRANSACTION_labelLocate = (android.os.IBinder.FIRST_CALL_TRANSACTION + 11);
    static final int TRANSACTION_labelPrintEnd = (android.os.IBinder.FIRST_CALL_TRANSACTION + 12);
    static final int TRANSACTION_labelLocateAuto = (android.os.IBinder.FIRST_CALL_TRANSACTION + 13);
    static final int TRANSACTION_labelDetectAuto = (android.os.IBinder.FIRST_CALL_TRANSACTION + 14);
    static final int TRANSACTION_hasLabelLearning = (android.os.IBinder.FIRST_CALL_TRANSACTION + 15);
    static final int TRANSACTION_clearLabelLearning = (android.os.IBinder.FIRST_CALL_TRANSACTION + 16);
    public static boolean setDefaultImpl(net.nyx.printerservice.print.IPrinterService impl) {
      // Only one user of this interface can use this function
      // at a time. This is a heuristic to detect if two different
      // users in the same process use this function.
      if (Stub.Proxy.sDefaultImpl != null) {
        throw new IllegalStateException("setDefaultImpl() called twice");
      }
      if (impl != null) {
        Stub.Proxy.sDefaultImpl = impl;
        return true;
      }
      return false;
    }
    public static net.nyx.printerservice.print.IPrinterService getDefaultImpl() {
      return Stub.Proxy.sDefaultImpl;
    }
  }
  public java.lang.String getServiceVersion() throws android.os.RemoteException;
  public int getPrinterVersion(java.lang.String[] ver) throws android.os.RemoteException;
  public int getPrinterModel(java.lang.String[] model) throws android.os.RemoteException;
  public int getPrinterStatus() throws android.os.RemoteException;
  public int paperOut(int px) throws android.os.RemoteException;
  public int paperBack(int px) throws android.os.RemoteException;
  public int printText(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat) throws android.os.RemoteException;
  /**
       * Print text
       *
       * @param text       text content
       * @param textFormat text format
       * @param textWidth  maximum text width, <384px
       * @param align      The alignment of the maximum text width relative to the 384px printing paper
       *                   The default is 0. 0--Align left, 1--Align center, 2--Align right
       * @return Print result
       */
  public int printText2(java.lang.String text, net.nyx.printerservice.print.PrintTextFormat textFormat, int textWidth, int align) throws android.os.RemoteException;
  /**
       * Print barcode
       *
       * @param content      barcode content
       * @param width        barcode width, px
       * @param height       barcode height, px
       * @param textPosition barcode content text position, the default is 0.
       *                     0--don't print barcode content
       *                     1--content above the barcode
       *                     2--content below the barcode
       *                     3--text print both the top and bottom of the barcode
       * @param align        alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
       * @return Print result
       */
  public int printBarcode(java.lang.String content, int width, int height, int textPosition, int align) throws android.os.RemoteException;
  /**
       * Print QR code
       *
       * @param content QRCode content
       * @param width   QRCode width, px
       * @param height  QRCode height, px
       * @param align   alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
       * @return Print result
       */
  public int printQrCode(java.lang.String content, int width, int height, int align) throws android.os.RemoteException;
  /**
       * Print bitmap
       *
       * @param bitmap Android bitmap object
       * @param type   printer render type, the default is 0.
       *               0--black and white bitmap
       *               1--grayscale bitmap, suitable for rich color images
       * @param align  alignment, the default is 0. 0--Align left, 1--Align center, 2--Align right
       * @return Print result
       */
  public int printBitmap(android.graphics.Bitmap bitmap, int type, int align) throws android.os.RemoteException;
  /**
       * Locate the next label
       *
       * @param labelHeight label paper height, px
       * @param labelGap    label paper gap, px
       * @return Result
       */
  public int labelLocate(int labelHeight, int labelGap) throws android.os.RemoteException;
  /**
       * Label printing ends, paper automatically moves to the tear-off position.
       * This method must appear in pairs with {@link #labelLocate}
       *
       * @return Result
       */
  public int labelPrintEnd() throws android.os.RemoteException;
  /**
       * Auto locate label. This method only can be called on the system that has performed
       * label learning by {@link #labelDetectAuto}
       *
       * @return Result
       */
  public int labelLocateAuto() throws android.os.RemoteException;
  /**
       * Label learning by automatic label detection. This method will start label learning
       *
       * @return Result
       */
  public int labelDetectAuto() throws android.os.RemoteException;
  /**
       * Label learning has been performed
       *
       * @return Result
       */
  public boolean hasLabelLearning() throws android.os.RemoteException;
  /**
       * Clear label learning data
       *
       * @return Result
       */
  public int clearLabelLearning() throws android.os.RemoteException;
}

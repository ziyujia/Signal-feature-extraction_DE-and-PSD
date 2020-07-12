function [ psd, de ] = STFT(data,stft_para)
%input: data [n*m]          n electrodes, m time points
%       stft_para.stftn     frequency domain sampling rate
%       stft_para.fStart    start frequency of each frequency band
%       stft_para.fEnd      end frequency of each frequency band
%       stft_para.window    window length of each sample point(seconds)
%       stft_para.f         original frequency
%output:psd,DE [n*l*k]        n electrodes, l windows, k frequency bands
   
    %initialize the parameters
    STFTN=stft_para.stftn;
    fStart=stft_para.fStart;
    fEnd=stft_para.fEnd;
    fs=stft_para.fs;
    window=stft_para.window;
    
    WindowPoints=fs*window;
    
    fStartNum=zeros(1,length(fStart));
    fEndNum=zeros(1,length(fEnd));
    for i=1:length(fStart)
        fStartNum(1,i)=fix(fStart(i)/fs*STFTN);
        fEndNum(1,i)=fix(fEnd(i)/fs*STFTN);
    end
    
    [n m]=size(data);
    l=fix(m/WindowPoints);
    psd=zeros(n,l,length(fStart));
    de = zeros(n, l, length(fStart));
    %Hanning window
    Hlength=window*fs;
    Hwindow=hanning(Hlength);
    
    WindowPoints=fs*window;
    for i=1:l
        dataNow=data(:,WindowPoints*(i-1)+1:WindowPoints*i);
        for j=1:n
            temp=dataNow(j,:);
            Hdata=temp.*Hwindow';
            FFTdata=fft(Hdata,STFTN);
            magFFTdata=abs(FFTdata(1:1:STFTN/2));
            for p=1:length(fStart)
                E=0;
                E_log = 0;
                for p0=fStartNum(p):fEndNum(p)
                    E=E+magFFTdata(p0)*magFFTdata(p0);
                %    E_log = E_log + log2(magFFTdata(p0)*magFFTdata(p0)+1);
                end
                E=E/(fEndNum(p)-fStartNum(p)+1);
                psd(j,i,p)= E;
                de(j,i,p) = log2(100*E);
                %de(j,i,p)=log2((1+E)^4);
            end
        end
    end                        
end



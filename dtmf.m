[tel,fs] = audioread('Ornek.wav');
d = floor(length(tel)/11);


myNumber=[0 1 2 3 4 5 6 7 8 9 9];
myTel=[];
for i=1:length(myNumber)%Telefon numaramın sesinin üretildiği döngü
    output = DTMF_Generator(myNumber(i),d/2);
    tmp=myTel;
    myTel = [tmp,output];
end
audiowrite('01234567899.wav',myTel,fs);


% plot(tel)
% title("Ornek.wav zaman düzlemi plot")
% stem(tel)
% title("Ornek.wav zaman düzlemi stem")
% plot(myTel)
% title("01234567899.wav zaman düzlemi plot")
% stem(myTel)
% title("01234567899.wav zaman düzlemi stem")

detectedNumber = [];
for i=0:10 %Ornek.wav dosyasındaki numaranın tespit edildiği döngü (02123835731)
    num = tel((i*d)+1:(i+1)*d);%her bir tuşlamanın ayrı ayrı vektörlere alınması---tel dizisi yerine myTel yazılırsa benim numaramı analiz eder
    X=fft(num);
    X_shift=abs(fftshift(X));
    f_shift=1:fs/d:fs/4;%frekans düzleminde x ekseni değerleri
    new_X_shift = X_shift(d/2+1:3*d/4);
    [~,index] = max(new_X_shift(1:d/8));%2 farklı frekansdan küçük olanı bulma işlemi
    f1 = f_shift(index);
    [~,index] = max(new_X_shift(d/8+1:d/4));%büyük frekansı bulma işlemi
    f2 = f_shift(index+d/8);
    number = DTMF_Decoder(f1,f2);%2 frekansın kontrol edilip tuşlamanın tespit edildiği fonksiyon
    detectedNumber(i+1) = number; 
    subplot(11,1,i+1)
    plot(f_shift,abs(new_X_shift))
    title("Tespit edilen tuşlama: " + number)
end

fprintf("Detected number: ")
for i=1:length(detectedNumber)%Tespit edilen numarayı ekrana yazdırma işlemi
    if detectedNumber(i) == 42 %ASCII karşılığı
        fprintf('* ');
    elseif detectedNumber(i) == 35 %ASCII karşılığı
        fprintf('# ');
    else
        fprintf('%s ',num2str(detectedNumber(i)));
    end
end

function dtmf_output = DTMF_Generator(num,d)
    %Tuşlanan karakter ile ilgili frekans değerlerinin oluşturduğu
    %fonksiyonları toplayıp geri dönen fonksiyon
    fs = 8000;
    t=0:1/fs:(d-1)/fs;
    A = 0.5;
    
    x1 = A *sin(2*pi*697*t); 
    x2 = A *sin(2*pi*770*t);
    x3 = A *sin(2*pi*852*t);
    x4 = A *sin(2*pi*941*t);
    
    y1 = A *sin(2*pi*1209*t);
    y2 = A *sin(2*pi*1336*t);
    y3 = A *sin(2*pi*1477*t);

    switch num
    case 1
        z = x1 + y1;
    case 2
        z = x1 + y2;
    case 3
        z = x1 + y3;
    case 4
        z = x2 + y1;
    case 5
        z = x2 + y2;
    case 6
        z = x2 + y3;
    case 7
        z = x3 + y1;
    case 8
        z = x3 + y2;
    case 9
        z = x3 + y3;
    case '*'
        z = x4 + y1;
    case 0
        z = x4 + y2;
    case '#' 
        z = x4 + y3;
    end
    z(d+1 : 2*d)=0;% Her bir tuşlama arasında kesinti olması için 0'lar eklenmiştir
    dtmf_output = z;
end

function num = DTMF_Decoder(f1,f2)
    %Parametre olarak gelen 2 frekansa göre tuşlanan değeri dönen fonksiyon
    if 690 < f1 && f1<710
        if 1200<f2 && f2<1220
            num=1;
        elseif 1330<f2 && f2<1350
            num=2;
        elseif 1470<f2 && f2<1490
            num=3;
        end
    elseif 760 < f1 && f1<780
        if 1200<f2 && f2<1220
            num=4;
        elseif 1330<f2 && f2<1350
            num=5;
        elseif 1470<f2 && f2<1490
            num=6;
        end
    elseif 840 < f1 && f1<860
        if 1200<f2 && f2<1220
            num=7;
        elseif 1330<f2 && f2<1350
            num=8;
        elseif 1470<f2 && f2<1490
            num=9;
        end
    elseif 930 < f1 && f1<950
        if 1200<f2 && f2<1220
            num='*';
        elseif 1330<f2 && f2<1350
            num=0;
        elseif 1470<f2 && f2<1490
            num='#';
        end
    end
end


create database Telif_Haklari
use Telif_Haklari

create table rol(
	rolId int primary key identity(1,1),
	rolAdi nvarchar(50) not null unique
)

create table kullanicilar(
	kullaniciId int primary key identity(1,1),
	kullaniciAdi nvarchar(50) not null unique,
	sifre nvarchar(50) not null,
	eposta nvarchar(50) unique,
	rolId int foreign key references rol(rolId)
)

create table yetkiler(
	yetkiId int primary key identity(1,1),
	yetkiTanimi nvarchar(50) not null,
	rolId int foreign key references rol(rolId)
)

insert into rol(rolAdi) values ('Admin'),('Kullanici');
insert into yetkiler(yetkiTanimi,rolId) values ('Uye Silme',1),('Eser Ekleme',1),('Eser Görüntüleme',2)
insert into kullanicilar(kullaniciAdi,sifre,rolId) values ('admin_deniz','deniz123',1)
select kullaniciId,kullaniciAdi,RolId from kullanicilar where kullaniciAdi= 'admin_deniz' and sifre= 'deniz123'

create table eserSahibi(
	sahipId int primary key identity(1,1),
	sahipAd nvarchar(50) not null,
	ulke nvarchar(50)
)

create table eserTuru(
	turId int primary key identity(1,1),
	turAdi nvarchar (50) not null unique
)

create table lisansTuru(
	lisansId int primary key identity(1,1),
	lisansAdi nvarchar (50) not null unique
)

create table turkiyeDagitimSorumlusu(
	dagitimciId int primary key identity(1,1),
	kurumAdi nvarchar(50) not null unique,
	iletisim nvarchar (50)
)

create table eserler(
	eserId int primary key identity(1,1),
	eserAdi nvarchar (50) not null,
	yayinTarihi date,
	turId int foreign key references eserTuru(turId),
	sahipId int foreign key references eserSahibi(sahipId),
	lisansId int foreign key references lisansTuru(lisansId),
	dagitimciId int foreign key references turkiyeDagitimSorumlusu(dagitimciId)
)

alter table eserler add eserDetay nvarchar (50)
alter table eserler drop column eserDetay

create table telifHakki(
	telifId int primary key identity(1,1),
	eserId int foreign key references eserler(eserId),
	sahipId int foreign key references eserSahibi(sahipId),
	lisansBaslangic date,
	lisansBitis date,
	durum nvarchar(50) default 'Aktif'
)

insert into eserTuru(turAdi) values ('İlim ve Edebiyat Eserleri'),
									('Musiki Eserleri'),
									('Güzel Sanat Eserleri'),
									('Sinema Eserleri'),
									('İşlenme ve Derlemeler')

insert into lisansTuru(lisansAdi) values ('CC BY'),
										 ('CC BY-SA'),
										 ('CC BY-NC'),
										 ('CC BY-ND'),
										 ('CC BY-NC-SA'),
										 ('CC BY-NC-ND'),
										 ('CC0'),
										 ('MIT'),
										 ('GNU'),
										 ('Apache'),
										 ('Proprietory'),
										 ('EULA'),
										 ('SaaS'),
										 ('Exclusive'),
										 ('Non-Exclusive'),
										 ('Public Domain')


insert into eserSahibi (sahipAd,ulke) values ('Alan Moore','Birleşik Krallık')
insert into turkiyeDagitimSorumlusu (kurumAdi, iletisim) values ('JBC Yayıncılık', 'info@jbcyayincilik.com')
insert into eserler(eserAdi, yayinTarihi, turId, sahipId, lisansId, dagitimciId) values 
	('V for Vendetta', 
    '1982-05-01', 
    (select turId from eserTuru where turAdi = 'İlim ve Edebiyat Eserleri'), 
    (select sahipId from eserSahibi where sahipAd = 'Alan Moore'),
    (select lisansId from lisansTuru where lisansAdi = 'Proprietory'),
    (select dagitimciId from turkiyeDagitimSorumlusu where kurumAdi = 'JBC Yayıncılık'))

insert into telifHakki (eserId,sahipId,lisansBaslangic,lisansBitis,durum) values (
    (select eserId from eserler where eserAdi = 'V for Vendetta'),
    (select sahipId from eserSahibi where sahipAd = 'Alan Moore'),
    '1982-05-01', 
    '2082-05-01', 
    'Aktif'
)

go
create function dbo.fn_telifDurumuKontrol ( @BitisTarihi date)
returns nvarchar(50)
as
begin
    declare @Durum nvarchar(50);
    declare @Fark int;
    
    set @Fark = datediff(day, GETDATE(), @BitisTarihi);
    
    if @Fark > 0
        set @Durum = 'Sözleşme Aktif (' + cast(@Fark as nvarchar(10)) + ' gün kaldı)';
    else
        set @Durum = 'Sözleşme Süresi Dolmuştur!';
        
    return @Durum;
end
go

create trigger trg_telifDurumOtomatize
on telifHakki
after insert, update 
as 
begin
	update telifHakki 
	set durum = 'Süresi Dolmuş'
	from telifHakki th
	inner join inserted i on th.telifId = i.telifId
	where i.lisansBitis < GETDATE()
end
go

create procedure sp_eserVeTelifKaydet
	@EserAdi nvarchar (50),
	@YayinTarihi date,
    @TurAdi nvarchar(50),
    @SahipAdi nvarchar(50),
    @LisansAdi nvarchar(50),
    @DagitimciAdi nvarchar(50),
    @LisansBitis date
as 
begin 
	begin try
		begin transaction;

		declare @v_TurId int = (select turId from eserTuru where turAdi = @TurAdi);
        declare @v_SahipId int = (select sahipId from eserSahibi where sahipAd = @SahipAdi);
        declare @v_LisansId int = (select lisansId from lisansTuru where lisansAdi = @LisansAdi);
        declare @v_DagitimciId int = (select dagitimciId from turkiyeDagitimSorumlusu where kurumAdi = @DagitimciAdi);

        insert into eserler (eserAdi, yayinTarihi, turId, sahipId, lisansId, dagitimciId)
        values (@EserAdi, @YayinTarihi, @v_TurId, @v_SahipId, @v_LisansId, @v_DagitimciId);

        declare @v_YeniEserId int = SCOPE_IDENTITY();

        insert into telifHakki (eserId, sahipId, lisansBaslangic, lisansBitis, durum)
        values (@v_YeniEserId, @v_SahipId, @YayinTarihi, @LisansBitis, 'Aktif');

        commit transaction; 
        print 'Eser ve Telif Hakkı başarıyla sisteme kaydedildi.';
    end try
    begin catch
        rollback transaction; 
        print 'HATA: Kayıt işlemi sırasında bir sorun oluştu!';
    end catch
end;
go

select 
    e.eseradi as [eser], 
    s.sahipad as [yazar], 
    t.turadi as [kategori]
from eserler e
join esersahibi s on e.sahipId = s.sahipId
join eserturu t on e.turId = t.turId;

select 
    t.turadi as [kategori], 
    count(e.eserId) as [toplam_eser]
from eserTuru t
left join eserler e on t.turId = e.turId
group by t.turAdi;

select 
    t.turadi as [kategori], 
    count(e.eserId) as [eser_sayisi]
from eserturu t
join eserler e on t.turId = e.turId
group by t.turAdi
having count(e.eserId) >= 1;
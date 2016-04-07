# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.destroy_all
p "**Prepare create users "
admin = User.create name: 'admin',
                    email: 'admin@fooways.com',
                    password: 'pwdadmin1234',
                    password_confirmation: 'pwdadmin1234',
                    role_identifier: :admin

frank = User.create name: 'frank',
                    email: 'frank@fooways.com',
                    password: '11111111',
                    password_confirmation: '11111111',
                    role_identifier: :operator

tom   = User.create name: 'tom',
                    email: 'tom@fooways.com',
                    password: '11111111',
                    password_confirmation: '11111111',
                    role_identifier: :store_manager
p "****#{User.count} users created successfully"

Instance.destroy_all
p "**Prepare create instances "
bs    = Instance.create name: 'kfc',
                        nick: '中国百胜餐饮连锁',
                        description: '上校鸡块，你值得拥有！',
                        phone: '4008123123',
                        email: 'tom@fooways.com',
                        creator_id: frank.id
bs.add_manager frank
dxe   = Instance.create name: 'diaoxiaoer',
                        nick: '上大店小二生活社区',
                        description: '足不出户，应有尽有！',
                        phone: '4008123124',
                        email: 'tom@fooways.com',
                        creator_id: frank.id
dxe.add_manager frank
bxs   = Instance.create name: 'banxiaoshi',
                        nick: '深圳半小时外卖有限公司',
                        description: '足不出户，应有尽有！',
                        phone: '4008123125',
                        email: 'tom@fooways.com',
                        creator_id: frank.id
bxs.add_manager frank
p "****#{Instance.count} instances created successfully"

Store.destroy_all
p "**Prepare create stores "
kfc           = Store.create  name: '中国肯德基',
                              description: '上校鸡块，你值得拥有！',
                              phone: '4008123126',
                              email: 'tom@fooways.com',
                              street: '北京西路1701号',
                              creator_id: frank.id
bs.stores << kfc
kfc.add_manager tom

burgerking    = Store.create  name: '汉堡王',
                              description: '超大汉堡，超值美味！',
                              phone: '4008123127',
                              email: 'tom@fooways.com',
                              street: '北京西路1701号',
                              creator_id: frank.id
bs.stores << burgerking
burgerking.add_manager tom

xiaoerkuaican = Store.create  name: '小二快餐',
                              description: '快速点餐，超值美味！',
                              phone: '4008123128',
                              email: 'tom@fooways.com',
                              street: '北京西路1701号',
                              creator_id: tom.id
dxe.stores << xiaoerkuaican
xiaoerkuaican.add_manager tom

banxiaoshi    = Store.create  name: '半小时外卖',
                              description: '快速点餐，半小时必达！',
                              phone: '4008123129',
                              email: 'tom@fooways.com',
                              street: '北京西路1701号',
                              creator_id: tom.id
bxs.stores << banxiaoshi
banxiaoshi.add_manager tom

p "****#{Store.count} stores created successfully"

p '**Prepare create categories'
  recommend = banxiaoshi.categories.create name: "推荐菜"
  cate_1    = banxiaoshi.categories.create name: "洞庭经典"
  cate_2    = banxiaoshi.categories.create name: "风味小吃"
  cate_3    = banxiaoshi.categories.create name: "时令鲜蔬"
  cate_4    = banxiaoshi.categories.create name: "洞庭汇鱼鲜"
  cate_5    = banxiaoshi.categories.create name: "楚乡蒸菜"
  cate_6    = banxiaoshi.categories.create name: "精美凉菜"
  cate_7    = banxiaoshi.categories.create name: "洞庭汇江南经典"
  cate_8    = banxiaoshi.categories.create name: "洞庭汇瓦罐养生汤"
  cate_9    = banxiaoshi.categories.create name: "洞庭汇特色招牌"
  cate_10   = banxiaoshi.categories.create name: "洞庭汇开胃前菜"
  cate_11   = banxiaoshi.categories.create name: "洞庭汇常德大盆菜"
  cate_12   = banxiaoshi.categories.create name: "洞庭汇点点心意"
  cate_13   = banxiaoshi.categories.create name: "湖南农家"
  cate_14   = banxiaoshi.categories.create name: "湖北家乡"
  cate_15   = banxiaoshi.categories.create name: "汤羹"
  cate_16   = banxiaoshi.categories.create name: "洞庭汇洞庭经典"
  cate_17   = banxiaoshi.categories.create name: "洞庭汇风味小吃"
  cate_18   = banxiaoshi.categories.create name: "洞庭汇时令鲜蔬"
  cate_19   = banxiaoshi.categories.create name: "洞庭汇洞庭汇鱼鲜"
  cate_20   = banxiaoshi.categories.create name: "洞庭汇楚乡蒸菜"
  cate_21   = banxiaoshi.categories.create name: "洞庭汇精美凉菜"
  cate_22   = banxiaoshi.categories.create name: "洞庭汇湖南农家"
  cate_23   = banxiaoshi.categories.create name: "洞庭汇湖北家乡"
  cate_24   = banxiaoshi.categories.create name: "洞庭汇汤羹"

p "****#{Category.count} stores created successfully"
  50.times do |i|
    WesellItem.create name: "自制有机豆腐 #{i}",
                      price: 32.0,
                      quantity: 1000,
                      unit_name: '例',
                      category_id: recommend.id,
                      store_id: banxiaoshi.id
  end

  20.times do |i|
    WesellItem.create name: "干锅千叶豆腐 #{i}",
                      price: 28.0,
                      quantity: 1000,
                      unit_name: '例',
                      category_id: cate_1.id,
                      store_id: banxiaoshi.id
  end

  50.times do |i|
    WesellItem.create name: "公安牛三鲜 #{i}",
                      price: 58.0,
                      quantity: 1000,
                      unit_name: '例',
                      category_id: cate_2.id,
                      store_id: banxiaoshi.id
  end

  20.times do |i|
    WesellItem.create name: "洞庭湖酸汤鮰鱼 #{i}",
                      price: 38.0,
                      quantity: 1000,
                      unit_name: '斤',
                      category_id: cate_3.id,
                      store_id: banxiaoshi.id
  end
p "****#{WesellItem.count} products created successfully"

p "prepare create customers"
  tom = Customer.create name: 'tom',
                        phone: '18620728375',
                        instance_id: bxs.id,
                        email: 'tom@fooways.com'
p "****#{Customer.count} customers created successfully"


Tag.create(name: "饮食")
SubTag.create(name: "中餐", tag_id: 1)
SubTag.create(name: "外卖", tag_id: 1)
SubTag.create(name: "西餐", tag_id: 1)
SubTag.create(name: "日韩", tag_id: 1)
SubTag.create(name: "东南亚", tag_id: 1)
SubTag.create(name: "零食甜品", tag_id: 1)


Tag.create(name: "家政")
SubTag.create(name: "干洗", tag_id: 2)
SubTag.create(name: "清洁", tag_id: 2)
SubTag.create(name: "通渠", tag_id: 2)
SubTag.create(name: "快递", tag_id: 2)
SubTag.create(name: "搬家", tag_id: 2)
SubTag.create(name: "订奶送水", tag_id: 2)
SubTag.create(name: "维修换锁", tag_id: 2)
SubTag.create(name: "保姆月嫂", tag_id: 2)

Tag.create(name: "教育")
SubTag.create(name: "学校", tag_id: 3)
SubTag.create(name: "培训", tag_id: 3)
SubTag.create(name: "家教", tag_id: 3)
SubTag.create(name: "兴趣班", tag_id: 3)


Tag.create(name: "便民")
SubTag.create(name: "装修", tag_id: 4)
SubTag.create(name: "回收", tag_id: 4)
SubTag.create(name: "宠物", tag_id: 4)
SubTag.create(name: "银行", tag_id: 4)
SubTag.create(name: "政务", tag_id: 4)
SubTag.create(name: "旅行社", tag_id: 4)
SubTag.create(name: "物业管理", tag_id: 4)
SubTag.create(name: "房产中介", tag_id: 4)
SubTag.create(name: "快照复印", tag_id: 4)
SubTag.create(name: "医院药店", tag_id: 4)
SubTag.create(name: "通信通讯", tag_id: 4)
SubTag.create(name: "物业管理", tag_id: 4)


Tag.create(name: "丽人")
SubTag.create(name: "美容SPA", tag_id: 5)
SubTag.create(name: "美发美甲", tag_id: 5)
SubTag.create(name: "化妆品", tag_id: 5)


Tag.create(name: "母婴")
SubTag.create(name: "早教", tag_id: 6)
SubTag.create(name: "母婴店", tag_id: 6)
SubTag.create(name: "游乐场", tag_id: 6)

Tag.create(name: "休闲")
SubTag.create(name: "酒吧", tag_id: 7)
SubTag.create(name: "KTV", tag_id: 7)
SubTag.create(name: "酒店", tag_id: 7)
SubTag.create(name: "电影院", tag_id: 7)
SubTag.create(name: "沐足保健", tag_id: 7)
SubTag.create(name: "运动健身", tag_id: 7)

Tag.create(name: "购物")
SubTag.create(name: "百货", tag_id: 8)
SubTag.create(name: "肉菜市场", tag_id: 8)
SubTag.create(name: "士多超市", tag_id: 8)

Tag.create(name: "交通")
SubTag.create(name: "学车", tag_id: 9)
SubTag.create(name: "维修保养", tag_id: 9)
SubTag.create(name: "打车租车", tag_id: 9)
SubTag.create(name: "车站船务", tag_id: 9)









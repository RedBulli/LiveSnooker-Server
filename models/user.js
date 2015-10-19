module.exports = function(Sequelize, DataTypes) {
  var schema = {
    email: { type: DataTypes.STRING, primaryKey: true }
  };

  var User = Sequelize.define("User", schema, {
    classMethods: {
      associate: function(models) {
        User.belongsToMany(models.League, {
          through: { model: models.Admin, unique: true },
          as: 'leagues',
          foreignKey: 'UserEmail',
          constraints: false
        });
      }
    }
  });
  return User;
};

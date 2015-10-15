module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    email: { type: DataTypes.STRING, allowNull: false }
  };

  var User = Sequelize.define("User", schema, {
    classMethods: {
      associate: function(models) {
        User.belongsToMany(models.League, { through: 'Admin' })
      }
    }
  });
  return User;
};

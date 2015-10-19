module.exports = function(Sequelize, DataTypes) {
  var schema = {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4
    },
    write: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
    UserEmail: { type: DataTypes.STRING, allowNull: false },
  };
  var Admin = Sequelize.define("Admin", schema, {
    classMethods: {
      associate: function(models) {
        Admin.belongsTo(models.League, { foreignKey: {allowNull: false}, onDelete: "CASCADE" });
        Admin.belongsTo(models.User, { foreignKey: 'UserEmail', constraints: false });
      }
    }
  });
  return Admin;
};
